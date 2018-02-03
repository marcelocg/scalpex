defmodule Scalpex.Application do
  @moduledoc """
  The OTP Application that fires the trader robot service
  """
  
  use Application

  def start(_type, args) do
    IO.puts("Application started with args: #{args}")
    children = [ {Scalpex.Trader, args} ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end