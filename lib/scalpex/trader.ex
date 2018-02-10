defmodule Scalpex.Trader do
  use WebSockex
  require Logger
  require Record
  alias Scalpex.Messages

  def startup(opts \\ []) do
    start_link(opts)
    |> login
  end
  
  def start_link(opts \\ []) do
    Logger.info "[StartLink] Trader start_link"
    WebSockex.start_link("wss://api_testnet.blinktrade.com/trade/", __MODULE__, %Scalpex.State{}, opts)
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
    {:reply, Messages.order_book_subscription(state), state}
  end
  # Full Order Book
  defp process_msg(%{"MsgType" => "W"} = msg, state) do
    Logger.info "Received Full Order Book #{inspect msg}"
    Logger.info "State is #{inspect state}"
    state = %{state | last_req: msg["MDReqID"]}
    {:ok, state}
  end
  
end