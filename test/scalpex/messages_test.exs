defmodule Scalpex.MessagesTest do
  use ExUnit.Case
  doctest Scalpex.Messages

  # messages are supposed to be Poison-encoded, so they are escaped strings here
  # it's kind of a smell but...
  setup_all do
    [
      state: %Scalpex.State{},

      U2: {:text, "{\"MsgType\":\"U2\",\"BalanceReqID\":1}"},
      V: {:text,  "{\"SubscriptionRequestType\":1,\"MsgType\":\"V\",\"MarketDepth\":2,\"MDUpdateType\":1,\"MDReqID\":1,\"MDEntryTypes\":[\"0\",\"1\"],\"Instruments\":[\"BTCBRL\"]}"},
      BE: {:text, "{\"Username\":\"#{Application.get_env( :scalpex, :APIKey )}\",\"UserReqTyp\":\"1\",\"UserReqID\":1,\"Password\":\"#{Application.get_env( :scalpex, :APIPassword )}\",\"MsgType\":\"BE\",\"FingerPrint\":\"35833900445b198864d8e9a548c277cb49ad8fce51d7a1e4a088252eacd4bc8d\",\"BrokerID\":\"#{Application.get_env( :scalpex, :APIBroker )}\"}"},
      
      order_book: %{"MDFullGrp" => [
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
                  "Symbol" => "BTCBRL"
                },
    ]
  end

  test "Extract the price of the orders at the top of the Order Book", fixture do
    assert Scalpex.Messages.extract_top_orders(fixture.order_book) == [["0", 3350020000000], ["1", 3379999000000]]
  end

  test "Creates a Login request message", fixture do
    assert Scalpex.Messages.login(fixture.state) == fixture."BE"
  end

  test "Creates a Balance request message", fixture do
    assert Scalpex.Messages.balance(fixture.state) == fixture."U2"
  end

  test "Creates an Order Book Subscription request message", fixture do
    assert Scalpex.Messages.order_book_subscription(fixture.state) == fixture."V"
  end

end
