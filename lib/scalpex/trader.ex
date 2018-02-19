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
        {:error, reason}

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
    |> calculate_spread
    |> decide_action(state)
  end
  
  @doc """
  Calculates the spread between the bid and and ask values currently presented at the top of the order book

  ## Examples
    iex> Scalpex.Trader.calculate_spread([bid: 3350020000000, ask: 3379999000000])
    0.8948901797601216

  """
  def calculate_spread([bid: bid, ask: ask]) do
    ((ask/bid) - 1) * 100
  end

  def decide_action(spread, %State{fee: fee, min_gain: min_gain} = state) when spread > (fee + min_gain) do
    {:reply, Messages.buy_order(state), state}
  end
  def decide_action(_spread, state) do
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

  # Initial HeartBeat
  defp process_msg(%{"MsgType" => "0"} = msg, state) do
    {:ok, %{state | session_id: msg["SessionID"]}}
  end
  # Logged in
  defp process_msg(%{"MsgType" => "BF"} = msg, state) do
    Logger.info "Logged in as #{msg["Username"]}"
    state = %{state | user_id: msg["UserID"], last_req: msg["UserReqID"]}
    {:reply, Messages.balance(state), state}
  end
  # Received Balance
  defp process_msg(%{"MsgType" => "U3"} = msg, state) do
    Logger.info "Current balance is: #{inspect msg}"
    broker_balance = msg[Application.get_env(:scalpex, :APIBroker)]
    fiat_symbol = Application.get_env(:scalpex, :APIFiat)
    state = %{state | last_req: msg["BalanceReqID"], fiat: broker_balance[fiat_symbol], btc: broker_balance["BTC"]}
    {:reply, Messages.order_book_subscription(state), state}
  end
  #Top of the Order Book
  defp process_msg(%{"MsgType" => "W"} = msg, state) do
    Logger.info "Received Top of the Order Book #{inspect msg}"
    state = %{state | last_req: msg["MDReqID"]}
    handle_order_book_top_update(msg, state)
  end
  # Incremental Order Book
  defp process_msg(%{"MsgType" => "X"} = msg, state) do
    Logger.info "Order Book Update #{inspect msg}"
    state = %{state | last_req: msg["MDReqID"]}
    {:ok, state}
  end
  # Undocumented messages, also unimplemented in the official client JS SDK 
  defp process_msg(%{"MsgType" => "U40"} = _msg, state) do
    Logger.warn "Received U40 message!"
    {:ok, state}
  end
  defp process_msg(%{"MsgType" => "U23"} = _msg, state) do
    Logger.warn "Received U23 message!"
    {:ok, state}
  end
  
end