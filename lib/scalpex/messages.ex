defmodule Scalpex.Messages do
  @moduledoc """
  This module provides functions for creating message payloads of the various message types as specified by the BlikTrade API
  """
  
  @doc """
  Creates an order book subscription request message

  https://blinktrade.com/docs/#subscribe-to-orderbook
  MDReqID                  Request ID
  SubscriptionRequestType	 “1” = Subscribe, “2” = Unsubscribe
  MarketDepth              “0” = Full Book, “1” = Top of Book
  MDEntryTypes             array(string)	“0” = Bid, “1” = Offer, “2” = Trade
  MDUpdateType             “0” = Full Refresh, “1” = Incremental RefreshRefresh
  Instruments	             Array with the symbols that you want to subscribe e.g.: [‘BTCBRL']
  """
  def order_book_subscription(state) do
    {:text, 
      %{MsgType: "V",
        MDReqID: state.last_req + 1,
        SubscriptionRequestType: 1,
        MarketDepth: 1,
        MDEntryTypes: ["0", "1"],
        MDUpdateType: 1,
        Instruments: ["BTCBRL"]}
      |> Poison.encode!
    }    
  end

  @doc """
  Creates a login request message

  https://blinktrade.com/docs/#authentication
  MsgType       BE
  UserReqID     Request Id
  BrokerID      <BROKER_ID>, see broker/1 below
  Username      The email address, username or API Key of the user
  Password      The password of the user
  UserReqTyp    “1”
  FingerPrint   Browser fingerprint
  """
  def login(state) do
    {:text, 
      %{MsgType: "BE",
        UserReqID: state.last_req + 1,
        BrokerID: Application.get_env( :scalpex, :APIBroker ),
        Username: Application.get_env( :scalpex, :APIKey ),
        Password: Application.get_env( :scalpex, :APIPassword ),
        UserReqTyp: "1",
        FingerPrint: Scalpex.Util.fingerprint()}
      |> Poison.encode!
    }
  end

  @doc """
  Creates a heartbeat message that keeps the connection open
  """
  def heartbeat do
    {:text, Poison.encode!(%{ "MsgType" => "1", "TestReqID" => "0", "SendTime" => System.system_time(:second)}) }
  end
end