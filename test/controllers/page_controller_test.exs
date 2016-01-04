defmodule Tbot.PageControllerTest do
  use Tbot.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "ThoughtBot"
  end
end
