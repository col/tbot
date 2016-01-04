defmodule Tbot.MessageHandlerTest do
  use Tbot.LibCase
  alias Tbot.MessageHandler
  alias Tbot.RollCall
  alias Tbot.RollCallResponse

  defp count(query), do: Repo.one(from v in query, select: count(v.id))

  @chat %{ id: 123 }
  @from %{ first_name: "Fred", id: 456 }
  @message %{ chat: @chat, from: @from, date: 1451868542}

  defp message(params \\ %{}) do
    Map.merge(@message, params)
  end

  test "/start_roll_call responds with 'Roll Call Started'" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert {status, response} == {:ok, "Roll call started"}
  end

  test "/start_roll_call creates a new RollCall" do
    assert count(RollCall) == 0
    MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert Repo.get_by(RollCall, %{chat_id: @chat.id, status: "open"}) != nil
  end

  test "/start_roll_call closes all existing roll calls for the same chat" do
    existing = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert Repo.get(RollCall, existing.id).status == "closed"
  end


  test "/end_roll_call responds with 'Roll call ended'" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "Roll call ended"}
  end

  test "/end_roll_call closes the existing roll call" do
    existing = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert Repo.get(RollCall, existing.id).status == "closed"
  end


  test "/in responds correctly" do
    roll_call = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    assert {status, response} == {:ok, "Fred is in!"}
  end

  test "/in records the users response" do
    roll_call = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    MessageHandler.handle_message(message(%{text: "/in"}))
    response = Repo.get_by!(RollCallResponse, %{status: "in", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end


  test "/out responds correctly" do
    roll_call = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
    assert {status, response} == {:ok, "Fred is out!"}
  end

  test "/out records the users response" do
    roll_call = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    MessageHandler.handle_message(message(%{text: "/out"}))
    response = Repo.get_by!(RollCallResponse, %{status: "out", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end


  test "/whos_in responds correctly" do
    roll_call = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
    response1 = Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1"})
    response2 = Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2"})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n\nOut\n - User 2\n"}
  end

end
