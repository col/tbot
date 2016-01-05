defmodule Tbot.TelegramMessageController do
  use Tbot.Web, :controller
  import Tbot.MessageHandler
  import Atom.Chars

  def create(conn, params) do
    message = to_atom(params).message
    if {:ok, response} = handle_message(message) do
       Nadia.send_message(message.chat.id, response)
    end
    json conn, %{}
  end

end
