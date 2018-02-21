defmodule Scalpex.Trader do
  use WebSockex
  require Logger
  require Record
  alias Scalpex.Messages
  alias Scalpex.State

  def startup() do
    start_link()
    |> login
  end
  
  def start_link(opts \\ []) do
    Logger.info "[StartLink] Trader start_link - OPTS: #{inspect opts}"
    WebSockex.start_link(Application.get_env( :scalpex, :APIUrl ), __MODULE__, %Scalpex.State{}, opts)
    |> after_connect
  end
  
  def login({client, state}) do
    WebSockex.send_frame(client, Messages.login(state))
    {client, state}
  end
  
  defp after_connect(result) do
    case result do
      {:error, %WebSockex.ConnError{original: reason}} ->
        Logger.info "Could not connect to the exchange. Reason: #{reason}"
        raise("Connection timeout.")

      {:ok, client} ->
        {_, state} = WebSockex.Utils.send(client, {:ping, %{%Scalpex.State{} | client: client}})
        start_heartbeat_generator(client)
        {client, state}
    end
  end

  def start_heartbeat_generator(client) do
    :timer.apply_interval(25_000, __MODULE__, :send_heartbeat, [client])
  end

  def send_heartbeat(client) do
    Logger.info "[HeartBeat] Pulse <3"
    WebSockex.send_frame(client, Messages.heartbeat)
  end

  def handle_order_book_top_update(msg, state) do
    msg
    |> Messages.extract_top_orders
    |> update_current_prices(state)
    |> update_spread
    |> decide_action
  end
  
  @doc """
  Updates the spread value in state data
  ## Examples
    iex> state = %Scalpex.State{}
    iex> state.current_bid
    -1
    iex> state.current_ask
    -1
    iex> state = Scalpex.Trader.update_current_prices([bid: 3350020000000, ask: 3379999000000], state)
    iex> state.current_bid
    3350020000000
    iex> state.current_ask
    3379999000000
  """
  def update_current_prices(prices, state) do
    bid = prices[:bid] 
    ask = prices[:ask]

    state = 
    case [bid, ask] do
      [nil, nil] -> state
      [bid, nil] -> %{state | current_bid: bid}
      [nil, ask] -> %{state | current_ask: ask}
      [bid, ask] -> %{state | current_bid: bid, current_ask: ask}
    end
    state
  end

  def update_spread(state) do
    state = %{state | spread: calculate_spread(state.current_bid, state.current_ask)}
    state
  end

  @doc """
  Calculates the spread between the bid and and ask values currently presented at the top of the order book
  ## Examples
    iex> Scalpex.Trader.calculate_spread(3350020000000, 3379999000000)
    0.8948901797601216
  """
  def calculate_spread(bid, ask) do
    ((ask/bid) - 1) * 100
  end

  def decide_action(%State{spread: spread, fee: fee, min_gain: min_gain} = state) when spread > (fee + min_gain) do
    Logger.info "Spread: #{spread} Current threshold: #{fee + min_gain}"
    {:reply, Messages.buy_order(state), state}
  end
  def decide_action(state) do
    {:ok, state}
  end

  #### Callbacks
  def handle_info(msg, state) do
    {:ok, %{state | client: elem(msg, 1).client}}
  end

  def handle_frame({_type, msg}, state) do
    case Poison.decode(msg) do
      {:error, error} ->
        Logger.debug(inspect msg)
        Logger.error(inspect error)
      {:ok, message} ->
        process_msg(message, state)
    end
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.info "[HandleCast] Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  defp process_msg(%{"MsgType" => type} = msg, state) do
    case type do
      "0"  -> respond_to_initial_hb(msg, state)
      "BF" -> respond_to_login(msg, state)
      "U3" -> respond_to_balance_received(msg, state)
      "W"  -> respond_to_order_book_update(msg, state)
      "X"  -> respond_to_order_book_update(msg, state)
      _    -> respond_to_other_messages(msg, state)
    end
  end

  defp respond_to_initial_hb(msg, state) do
    {:ok, %{state | session_id: msg["SessionID"]}}
  end

  defp respond_to_login(msg, state) do
    Logger.info "Logged in as #{msg["Username"]}"
    state = %{state | user_id: msg["UserID"], last_req: msg["UserReqID"]}
    {:reply, Messages.balance(state), state}
  end

  defp respond_to_balance_received(msg, state) do
    Logger.info "Current balance is: #{inspect msg}"
    broker_balance = msg[Application.get_env(:scalpex, :APIBroker)]
    fiat_symbol = Application.get_env(:scalpex, :APIFiat)
    state = %{state | last_req: msg["BalanceReqID"], fiat_bal: broker_balance[fiat_symbol], btc_bal: broker_balance["BTC"]}
    {:reply, Messages.order_book_subscription(state), state}
  end

  defp respond_to_order_book_update(msg, state) do
    Logger.info "Received Top of the Order Book #{inspect msg}"
    state = %{state | last_req: msg["MDReqID"]}
    Logger.info inspect state
    handle_order_book_top_update(msg, state)
  end

  defp respond_to_other_messages(%{"MsgType" => type} = _msg, state) do
    Logger.warn "Received #{type} message!"
    {:ok, state}
  end  
end