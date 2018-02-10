defmodule Scalpex.State do
  defstruct env: :test, fee: 0.5, min_gain: 0.03, session_id: nil, user_id: nil, client: nil, last_req: 0
end