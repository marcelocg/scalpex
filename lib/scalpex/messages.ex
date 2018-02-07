defmodule Scalpex.Messages do
  @moduledoc """
  This module provides functions for creating message payloads of the various message types as specified by the BlikTrade API
  """

  def create_login_message(), do: create_login_message(0)
  def create_login_message(last_req), do: create_login_message(last_req, :test)
  def create_login_message(last_req, env) do
    %{MsgType: "BE",
      UserReqID: last_req + 1,
      BrokerID: broker(env),
      Username: Application.get_env( :scalpex, :APIKey ),
      Password: Application.get_env( :scalpex, :APIPassword ),
      UserReqTyp: "1",
      FingerPrint: Scalpex.Util.fingerprint()}
  end

  defp broker(:test), do: 5 # BlinkTrade Testnet
  defp broker(:prod), do: 4 # FoxBit
end