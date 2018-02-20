defmodule Scalpex.TraderTest do
  use ExUnit.Case
  doctest Scalpex.Trader

  test "Responds correctly according to a given spread" do
    assert {:reply, _, _} = Scalpex.Trader.decide_action(10_000, %Scalpex.State{})
    assert {:ok, _}       = Scalpex.Trader.decide_action(0.001, %Scalpex.State{})
  end

end
