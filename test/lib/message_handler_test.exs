defmodule Tbot.MessageHandlerTest do
  use Tbot.LibCase
  alias Tbot.MessageHandler
  alias Tbot.RollCall
  alias Tbot.RollCallResponse

  defp count(query), do: Repo.one(from v in query, select: count(v.id))

  @chat %{ id: 123 }
  @from %{ first_name: "Fred", id: 456 }
  @message %{ chat: @chat, from: @from, date: 1451868542}

  defp message(params) do
    Map.merge(@message, params)
  end

  setup config do
    if config[:roll_call_open] do
      roll_call = Repo.insert!(%RollCall{ chat_id: @chat.id, status: "open" })
      {:ok, roll_call: roll_call}
    else
      :ok
    end
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

  test "'/start_roll_call Monday Night Football' responds with 'Monday Night Football roll call started'" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/start_roll_call Monday Night Football"}))
    assert {status, response} == {:ok, "Monday Night Football roll call started"}
  end

  test "'/start_roll_call Monday Night Football' creates a new RollCall with a title" do
    assert count(RollCall) == 0
    MessageHandler.handle_message(message(%{text: "/start_roll_call Monday Night Football"}))
    response = Repo.get_by(RollCall, %{chat_id: @chat.id, status: "open"})
    assert response != nil
    assert response.title == "Monday Night Football"
  end

  @tag :roll_call_open
  test "/start_roll_call closes all existing roll calls for the same chat", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/start_roll_call"}))
    assert Repo.get(RollCall, roll_call.id).status == "closed"
  end


  @tag :roll_call_open
  test "/end_roll_call responds with 'Roll call ended'" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "Roll call ended"}
  end

  @tag :roll_call_open
  test "/end_roll_call responds with the title when it's been set" do
    RollCall.changeset(Repo.one(RollCall), %{title: "Monday Night Football"}) |> Repo.update!
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "Monday Night Football roll call ended"}
  end

  test "/end_roll_call responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/end_roll_call closes the existing roll call", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/end_roll_call"}))
    assert Repo.get(RollCall, roll_call.id).status == "closed"
  end


  @tag :roll_call_open
  test "/in responds correctly" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    assert {status, response} == {:ok, "1. Fred\n"}
  end

  test "/in responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/in"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/in records the users response", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/in"}))
    response = Repo.get_by!(RollCallResponse, %{status: "in", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end

  @tag :roll_call_open
  test "/in updates an existing response", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: @from.id, name: @from.first_name})
    MessageHandler.handle_message(message(%{text: "/in"}))
    assert Repo.one!(RollCallResponse).status == "in"
  end


  @tag :roll_call_open
  test "/out responds correctly" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
    assert {status, response} == {:ok, "Out\n - Fred\n"}
  end

  test "/out responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/out"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/out records the users response", %{ roll_call: roll_call } do
    MessageHandler.handle_message(message(%{text: "/out"}))
    response = Repo.get_by!(RollCallResponse, %{status: "out", user_id: @from.id, name: @from.first_name})
    assert response.roll_call_id == roll_call.id
  end

  @tag :roll_call_open
  test "/out updates an existing response", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: @from.id, name: @from.first_name})
    MessageHandler.handle_message(message(%{text: "/out"}))
    assert Repo.one!(RollCallResponse).status == "out"
  end


  @tag :roll_call_open
  test "/whos_in lists all the in and out responses", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1"})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2"})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n\nOut\n - User 2\n"}
  end

  @tag :roll_call_open
  test "/whos_in lists includes the title when it's been set", %{ roll_call: roll_call } do
    RollCall.changeset(roll_call, %{title: "Monday Night Football"}) |> Repo.update!
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1"})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2"})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "Monday Night Football\n1. User 1\n\nOut\n - User 2\n"}
  end

  test "/whos_in responds with an error message when no active roll call exists" do
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "No roll call in progress"}
  end

  @tag :roll_call_open
  test "/whos_in doesn't print an empty out list", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1"})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n"}
  end

  @tag :roll_call_open
  test "/whos_in doesn't print an empty in list", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2"})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "Out\n - User 2\n"}
  end

  @tag :roll_call_open
  test "/whos_in lists 'in' people in correct order", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 2, name: "User 2", updated_at: Ecto.DateTime.from_erl({{2015, 2, 2}, {2, 2, 2}})})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "in", user_id: 1, name: "User 1", updated_at: Ecto.DateTime.from_erl({{2015, 1, 1}, {1, 1, 1}})})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "1. User 1\n2. User 2\n"}
  end

  @tag :roll_call_open
  test "/whos_in lists 'out' people in correct order", %{ roll_call: roll_call } do
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 2, name: "User 2", updated_at: Ecto.DateTime.from_erl({{2015, 2, 2}, {2, 2, 2}})})
    Repo.insert!(%RollCallResponse{ roll_call_id: roll_call.id, status: "out", user_id: 1, name: "User 1", updated_at: Ecto.DateTime.from_erl({{2015, 1, 1}, {1, 1, 1}})})
    {status, response} = MessageHandler.handle_message(message(%{text: "/whos_in"}))
    assert {status, response} == {:ok, "Out\n - User 1\n - User 2\n"}
  end

  @tag :roll_call_open
  test "/set_title sets the title of the roll call", %{ roll_call: roll_call } do
    {status, response} = MessageHandler.handle_message(message(%{text: "/set_title Monday Night Football"}))
    assert {status, response} == {:ok, "Roll call title set"}
    roll_call = Repo.get(RollCall, roll_call.id)
    assert roll_call.title == "Monday Night Football"
  end

end
