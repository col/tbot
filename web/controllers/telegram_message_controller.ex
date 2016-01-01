defmodule Tbot.TelegramMessageController do
  use Tbot.Web, :controller

  def create(conn, params) do
    # TODO: do something with the messages here!
    render conn, "show.html", update: params["update"]
  end

  def show(conn, params) do
    render conn, "show.html", update: params["update"]
  end

end
