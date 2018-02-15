defmodule Scalpex.MessagesTest do
  use ExUnit.Case

  setup_all do
    msg = %{"MDFullGrp" => [
              %{"Broker" => "foxbit", 
                "MDEntryDate" => "2018-02-15", 
                "MDEntryID" => 1459161956496, 
                "MDEntryPositionNo" => 1, 
                "MDEntryPx" => 3350020000000, 
                "MDEntrySize" => 1510000, 
                "MDEntryTime" => "08:55:20", 
                "MDEntryType" => "0", 
                "OrderID" => 1459161956496, 
                "UserID" => 00000007
              }, 
              %{"Broker" => "foxbit", 
                "MDEntryDate" => "2018-02-15", 
                "MDEntryID" => 1459161956495, 
                "MDEntryPositionNo" => 2, 
                "MDEntryPx" => 3350019000000, 
                "MDEntrySize" => 2985056, 
                "MDEntryTime" => "08:55:18", 
                "MDEntryType" => "0", 
                "OrderID" => 1459161956495, 
                "UserID" => 00000008
              }, 
              %{"Broker" => "foxbit", 
                "MDEntryDate" => "2018-02-15", 
                "MDEntryID" => 1459161956499, 
                "MDEntryPositionNo" => 1, 
                "MDEntryPx" => 3379999000000, 
                "MDEntrySize" => 24737338, 
                "MDEntryTime" => "08:55:25", 
                "MDEntryType" => "1", 
                "OrderID" => 1459161956499, 
                "UserID" => 00000009
              }, 
              %{"Broker" => "foxbit",
                "MDEntryDate" => "2018-01-31", 
                "MDEntryID" => 1459161354265, 
                "MDEntryPositionNo" => 2, 
                "MDEntryPx" => 3380000000000, 
                "MDEntrySize" => 21955187, 
                "MDEntryTime" => "15:39:46", 
                "MDEntryType" => "1", 
                "OrderID" => 1459161354265, 
                "UserID" => 00000001
              }
            ], 
          "MDReqID" => 3, 
          "MarketDepth" => 2, 
          "MsgType" => "W", 
          "Symbol" => "BTCBRL"}
  end

  test "Extract the price of the orders at the top of the Order Book", msg do
    assert Scalpex.Messages.extract_top_orders(msg) == [["0", 3350020000000], ["1", 3379999000000]]
  end

  doctest Scalpex.Messages
end
