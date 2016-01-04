defmodule Tbot.TelegramMessageController do
  use Tbot.Web, :controller

  def create(conn, params) do
    # TODO: do something with the messages here!
    IO.puts "Message received!"
    IO.puts "Keys: #{Map.keys(params)}"
    json conn, %{ status: "ok", update: params["update"] }
  end

  def show(conn, params) do
    render conn, "show.html", update: params["update"]
  end

end
