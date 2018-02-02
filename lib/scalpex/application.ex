defmodule Scalpex.Application do
  @moduledoc """
  The OTP Application that fires the trader robot service
  """
  
  use Application

  def start(_type, _args) do
    IO.puts("Start")
    children = [ {Scalpex.Trader, []} ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end