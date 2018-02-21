defmodule Scalpex.State do
  defstruct fee: 0.5, 
            min_gain: 0.3, 
            session_id: nil, 
            user_id: nil, 
            client: nil, 
            last_req: 0, 
            fiat_bal: 0, 
            btc_bal: 0,
            spread: 0,
            current_bid: -1,
            current_ask: -1,
            current_buy_price: 0,
            current_buy_qty: 0
end