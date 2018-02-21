defmodule Scalpex.TraderTest do
  use ExUnit.Case
  doctest Scalpex.Trader

  test "Responds correctly according to a given spread" do
    state = %Scalpex.State{}
    assert {:reply, _, _} = Scalpex.Trader.decide_action(%{state | spread: 10_000})
    assert {:ok, _}       = Scalpex.Trader.decide_action(%{state | spread: 0.0001})
    assert {:ok, _}       = Scalpex.Trader.decide_action(%{state | spread: 0})
  end

end
