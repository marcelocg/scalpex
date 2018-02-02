defmodule Scalpex.Trader do
  use WebSockex
  require Logger

  def start_link(opts \\ []) do
    IO.puts "Trader start_link"
    WebSockex.start_link("wss://api_testnet.blinktrade.com/trade/", __MODULE__, :fake_state, opts)
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, body}
  end

  def handle_response({_, %{status_code: _, body: body}}) do
    {:error, body}
  end
end