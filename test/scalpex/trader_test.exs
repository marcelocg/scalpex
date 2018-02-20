defmodule Scalpex.TraderTest do
  use ExUnit.Case
  doctest Scalpex.Trader

  test "Responds correctly according to a given spread" do
    assert {:reply, _, _} = Scalpex.Trader.decide_action(10_000, %Scalpex.State{})
  end

end
