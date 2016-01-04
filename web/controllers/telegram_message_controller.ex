defmodule Tbot.TelegramMessageController do
  use Tbot.Web, :controller
  import Tbot.MessageHandler
  import Atom.Chars

  def create(conn, params) do
    message = to_atom(params).message
    case Tbot.MessageHandler.handle_message(message) do
      {:ok, response} -> Nadia.send_message(message.chat.id, response)
    end
    json conn, %{}
  end

  def show(conn, params) do
    render conn, "show.html", update: params["update"]
  end

end

defimpl String.Chars, for: Map do
  def to_string(map) do
    Map.keys(map)
      |> List.foldl "", fn key, acc ->
        acc <> "\n#{key}: #{Map.get(map, key)}"
      end
  end
end
