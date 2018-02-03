defmodule Scalpex.Trader do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    IO.puts "Trader start_link"
    WebSockex.start_link("wss://api_testnet.blinktrade.com/trade/", __MODULE__, %Scalpex.State{}, opts)
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message:\n#{msg}\nState:\n#{state}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end