defmodule Scalpex.TraderTest do
  use ExUnit.Case
  doctest Scalpex.Trader

  test "Responds correctly according to a given spread" do
    state = %Scalpex.State{spread: 10_000}

    {:reply, {:text, msg}, _} = Scalpex.Trader.decide_action(%{state | position: :out})
    # Buy
    assert msg =~ ~s("MsgType":"D")
    assert msg =~ ~s("Side":"1")
    
    assert {:ok, _}       = Scalpex.Trader.decide_action(%{state | spread: 0.0001})
    assert {:ok, _}       = Scalpex.Trader.decide_action(%{state | spread: 0})
  end

end
