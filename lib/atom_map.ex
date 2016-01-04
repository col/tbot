defprotocol Atom.Chars do
  def to_atom(thing)
end

defimpl Atom.Chars, for: Map do

  def to_atom(map) do
    for {key, val} <- map, into: %{} do
      if is_map(val) do
        val = to_atom(val)
      end
      {String.to_atom(key), val}
    end
  end

end
