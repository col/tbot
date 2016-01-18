defmodule Tbot.TelegramMessageController do
  use Tbot.Web, :controller
  import Tbot.MessageHandler
  import Atom.Chars

  def create(conn, params) do
    message = Map.get(to_atom(params), :message, %{})
    case handle_message(message) do
      {:ok, response} ->
        Nadia.send_message(message.chat.id, response)
      {:error, _} ->
    end
    json conn, %{}
  end

end
