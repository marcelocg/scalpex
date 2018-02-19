defmodule Scalpex.Util do

  def fingerprint do
    case Mix.env do
      :prod -> :crypto.hash(:sha256, info())
               |> Base.encode16
               |> String.downcase
      _ -> "35833900445b198864d8e9a548c277cb49ad8fce51d7a1e4a088252eacd4bc8d"
    end
  end
  
  def info do
    data() 
    |> Enum.join(" ")
  end

  def data do
    [
      spec(),
      Scalpex.System.cpu_speed(),
      Scalpex.System.available_memory(),
      ip_info()
    ]
    |> List.flatten
  end

  def spec do
    spec = Application.spec(:scalpex)
    "Scalpex v#{Access.get(spec, :vsn)}"
  end

  def ip_info do
    {:ok,{_, _host, _,_, _, ips}} = :inet.gethostbyname(:net_adm.localhost())

    ips 
    |> Enum.map(fn(a) -> Tuple.to_list(a) |> Enum.join(".") end) 
  end
end