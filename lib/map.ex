defimpl String.Chars, for: Map do
  def to_string(map) do
    Map.keys(map)
    |> List.foldl("", fn key, acc -> acc <> "\n#{key}: #{Map.get(map, key)}" end)
  end
end
