defmodule Tbot.PageController do
  use Tbot.Web, :controller

  def index(conn, _params) do
    {:ok, %{first_name: first_name}} = Nadia.get_me
    render conn, "index.html", first_name: first_name
  end

end
