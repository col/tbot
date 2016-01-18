defmodule Tbot.TelegramMessageControllerTest do
  use Tbot.ConnCase

  @message %{
    message: %{
      chat: %{ id: 123 },
      from: %{ first_name: "Me", id: 456 },
      text: "/start_roll_call",
      date: 1451868542
    }
  }

  test "POST /telegram/message", %{conn: conn} do
    conn = post conn, "/telegram/message", @message
    assert json_response(conn, 200)
  end

  test "POST /telegram/message handles errors correctly", %{conn: conn} do
    conn = post conn, "/telegram/message", %{}
    assert json_response(conn, 200)
  end

end
