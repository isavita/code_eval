defmodule CodeEval.Cache do
  def fetch(code) do
    cache_key = create_cache_key(code)
    Cachex.get(:code_cache, cache_key)
  end

  def store(code, result) do
    cache_key = create_cache_key(code)
    Cachex.put(:code_cache, cache_key, result)
  end

  def reset! do
    Cachex.reset!(:code_cache)
  end

  defp create_cache_key(code) when is_binary(code) do
    :crypto.hash(:sha256, code) |> Base.encode16()
  end

  defp create_cache_key(_), do: "5DA3A4C7F117944275B4C8629C4916403625D5A4A6573A01ECB03F0E9D2EDBE6"
end
