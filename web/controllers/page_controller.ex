defmodule Tbot.PageController do
  use Tbot.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

end
