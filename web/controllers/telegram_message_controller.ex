defmodule Tbot.TelegramMessageController do
  use Tbot.Web, :controller
  import Tbot.MessageHandler
  import Atom.Chars

  def create(conn, params) do
    message = to_atom(params).message
    {status, response} = Tbot.MessageHandler.handle_message(message)
    Nadia.send_message(message.chat.id, response, [{:reply_to_message_id, message.message_id}])
    json conn, %{ status: "ok" }
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
