defmodule Scalpex.MessagesTest do
  use ExUnit.Case
  doctest Scalpex.Messages

  # messages are supposed to be Poison-encoded, so they are escaped strings here
  # it's kind of a smell but...
  setup_all do
    fingerprint = "35833900445b198864d8e9a548c277cb49ad8fce51d7a1e4a088252eacd4bc8d"
    [
      state: %Scalpex.State{},

      U2: {:text, ~s({"MsgType":"U2","BalanceReqID":1})},
      D:  {:text, ~s({"Symbol":"BTCBRL","Side":"1","Price":0,"OrderQty":0,"OrdType":"2","MsgType":"D","ClOrdID":1,"BrokerID":"#{Application.get_env( :scalpex, :APIBroker )}"})},
      V:  {:text, ~s({"SubscriptionRequestType":1,"MsgType":"V","MarketDepth":2,"MDUpdateType":1,"MDReqID":1,"MDEntryTypes":["0","1"],"Instruments":["BTCBRL"]})},
      BE: {:text, ~s({"Username":"#{Application.get_env( :scalpex, :APIKey )}","UserReqTyp":"1","UserReqID":1,"Password":"#{Application.get_env( :scalpex, :APIPassword )}","MsgType":"BE","FingerPrint":"#{fingerprint}","BrokerID":"#{Application.get_env( :scalpex, :APIBroker )}"})},
      
      incr_order_book_type_4_entry: %{"MDBkTyp" => "3",
                                      "MDIncGrp" => [ %{"BRL" => 14551739956627419,
                                                        "BTC" => 436677272829,
                                                        "MDEntryType" => "4"
                                                      }
                                                    ],
                                      "MDReqID" => 3,
                                      "MsgType" => "X"
                                    },

      incr_1_order_book_pos_2_only: %{"MDBkTyp" => "3",
                                      "MDIncGrp" => [ %{"Broker" => "foxbit",
                                                        "MDEntryDate" => "2018-02-20",
                                                        "MDEntryID" => 1459162179652,
                                                        "MDEntryPositionNo" => 2,
                                                        "MDEntryPx" => 3350020000000,
                                                        "MDEntrySize" => 20000000,
                                                        "MDEntryTime" => "15:38:08",
                                                        "MDEntryType" => "0",
                                                        "MDUpdateAction" => "0",
                                                        "OrderID" => 1459162179652,
                                                        "Symbol" => "BTCBRL",
                                                        "UserID" => 91045399
                                                      }
                                                    ],
                                      "MDReqID" => 3,
                                      "MsgType" => "X"
                                    },

      incr_1_order_book_pos_1_only: %{"MDBkTyp" => "3",
                                      "MDIncGrp" => [ %{"Broker" => "foxbit",
                                                        "MDEntryDate" => "2018-02-20",
                                                        "MDEntryID" => 1459162179652,
                                                        "MDEntryPositionNo" => 1,
                                                        "MDEntryPx" => 3350020000000,
                                                        "MDEntrySize" => 20000000,
                                                        "MDEntryTime" => "15:38:08",
                                                        "MDEntryType" => "0",
                                                        "MDUpdateAction" => "0",
                                                        "OrderID" => 1459162179652,
                                                        "Symbol" => "BTCBRL",
                                                        "UserID" => 91045399
                                                      }
                                                    ],
                                      "MDReqID" => 3,
                                      "MsgType" => "X"
                                    },

      incr_2_order_book_pos_1_only: %{"MDBkTyp" => "3",
                                      "MDIncGrp" => [ %{"Broker" => "foxbit",
                                                        "MDEntryDate" => "2018-02-20",
                                                        "MDEntryID" => 1459162179652,
                                                        "MDEntryPositionNo" => 1,
                                                        "MDEntryPx" => 3350020000000,
                                                        "MDEntrySize" => 20000000,
                                                        "MDEntryTime" => "15:38:08",
                                                        "MDEntryType" => "0",
                                                        "MDUpdateAction" => "0",
                                                        "OrderID" => 1459162179652,
                                                        "Symbol" => "BTCBRL",
                                                        "UserID" => 91045399
                                                      },
                                                      %{"Broker" => "foxbit",
                                                        "MDEntryDate" => "2018-02-20",
                                                        "MDEntryID" => 1459162179652,
                                                        "MDEntryPositionNo" => 1,
                                                        "MDEntryPx" => 3379999000000,
                                                        "MDEntrySize" => 20000000,
                                                        "MDEntryTime" => "15:38:08",
                                                        "MDEntryType" => "1",
                                                        "MDUpdateAction" => "0",
                                                        "OrderID" => 1459162179652,
                                                        "Symbol" => "BTCBRL",
                                                        "UserID" => 91045399
                                                      }
                                                    ],
                                      "MDReqID" => 3,
                                      "MsgType" => "X"
                                    },

      full_order_book: %{"MDFullGrp" => [
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

  test "Correctly interpret the ask and bid values in the order book" do
    assert Scalpex.Messages.extract_order_data("0", 1) == [bid: 1]
    assert Scalpex.Messages.extract_order_data("1", 2) == [ask: 2]
    assert Scalpex.Messages.extract_order_data("X", 2) == []
  end

  test "Extract the price of the orders at the top of the Order Book", fixture do
    assert Scalpex.Messages.extract_top_orders(fixture.full_order_book) == [bid: 3350020000000, ask: 3379999000000]
    assert Scalpex.Messages.extract_top_orders(fixture.incr_2_order_book_pos_1_only) == [bid: 3350020000000, ask: 3379999000000]
    assert Scalpex.Messages.extract_top_orders(fixture.incr_1_order_book_pos_1_only) == [bid: 3350020000000]
    assert Scalpex.Messages.extract_top_orders(fixture.incr_1_order_book_pos_2_only) == []
    assert Scalpex.Messages.extract_top_orders(fixture.incr_order_book_type_4_entry) == []
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

  test "Creates a Buy Order request message", fixture do
    assert Scalpex.Messages.buy_order(fixture.state) == fixture."D"
  end

end
