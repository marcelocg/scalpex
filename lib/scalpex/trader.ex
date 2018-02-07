defmodule Scalpex.Trader do
  use WebSockex
  require Logger
  require Record

  def start_link(opts \\ []) do
    Logger.info "Trader start_link"
    {:ok, pid} = WebSockex.start_link("wss://api_testnet.blinktrade.com/trade/", __MODULE__, %Scalpex.State{}, opts)
    Logger.info "WebSockEx PID=#{inspect pid} SelfPID=#{inspect self()}"
    {:ok, pid}
  end

  def handle_connect(conn, state) do
    Logger.info("Connected! Conn= #{inspect conn} State= #{inspect state}")
    {:ok, state}
  end
  
  def handle_frame({type, msg}, state) do
    Logger.info "Received Message - Type: #{inspect type}\nMessage: #{msg}\nState: #{state.env}"
    
    case Poison.decode(msg) do
      {:error, error} ->
        Logger.debug(inspect msg)
        Logger.error(inspect error)
      {:ok, message} ->
        process_msg(message, state)
    end
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.info "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  # Initial HeartBeat 
  defp process_msg(%{"MsgType" => "0"} = msg, state) do
    Logger.info "Received initial HeartBeat - #{inspect msg}"
    {:ok, %{state | session_id: msg["SessionID"]}}
  end
end