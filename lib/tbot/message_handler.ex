defmodule Tbot.MessageHandler do
  import Ecto.Query, only: [from: 2]
  import Tbot.RollCallResponse, only: [for_roll_call: 2, with_status: 2]
  alias Tbot.Repo
  alias Tbot.RollCall
  alias Tbot.RollCallResponse

  def handle_message(message = %{text: text}) when text == "/start_roll_call" do
    close_existing_roll_calls(message)
    start_roll_call(message)
    {:ok, "Roll call started"}
  end

  def handle_message(message = %{text: text}) when text == "/end_roll_call" do
    case roll_call_for_message(message) do
      nil ->
        {:ok, "No roll call in progress"}
      roll_call ->
        close_existing_roll_calls(message)
        {:ok, "Roll call ended"}
    end
  end

  def handle_message(message = %{text: text}) when text == "/in" do
    case roll_call_for_message(message) do
      nil ->
        {:ok, "No roll call in progress"}
      roll_call ->
        update_attendance(roll_call, message, "in")
        roll_call = roll_call_for_message(message)
        {:ok, whos_in_list(roll_call)}
    end
  end

  def handle_message(message = %{text: text}) when text == "/out" do
    case roll_call_for_message(message) do
      nil ->
        {:ok, "No roll call in progress"}
      roll_call ->
        update_attendance(roll_call, message, "out")
        roll_call = roll_call_for_message(message)
        {:ok, whos_in_list(roll_call)}
    end
  end

  def handle_message(message = %{text: text}) when text == "/whos_in" do
    case roll_call_for_message(message) do
      nil ->
        {:ok, "No roll call in progress"}
      roll_call ->
        roll_call = roll_call_for_message(message)
        {:ok, whos_in_list(roll_call)}
    end
  end

  def handle_message(message)do
    {:error, "Unknown message: #{to_string(message)}"}
  end

  defp roll_call_for_message(message) do
    roll_call = Repo.get_by(RollCall, %{chat_id: message.chat.id, status: "open"})
    if roll_call != nil do
      Repo.preload(roll_call, :responses)
    end
    roll_call
  end

  defp whos_in_list(roll_call) do
    output = []

    in_list = in_response_list(roll_call)
    if String.length(in_list) > 0 do
      output = output ++ [in_list]
    end

    out_list = out_response_list(roll_call)
    if String.length(out_list) > 0 do
      output = output ++ [out_list]
    end

    Enum.join(output, "\n")
  end

  defp in_response_list(roll_call) do
    output = ""
    in_responses = RollCallResponse |> for_roll_call(roll_call) |> with_status("in") |> Repo.all
    unless Enum.empty?(in_responses) do
      output = Enum.with_index(in_responses)
      |> Enum.reduce("", fn({response, index}, acc) -> acc <> "#{index+1}. #{response.name}\n" end)
    end
    output
  end

  defp out_response_list(roll_call) do
    output = ""
    out_responses = RollCallResponse |> for_roll_call(roll_call) |> with_status("out") |> Repo.all
    unless Enum.empty?(out_responses) do
      output = output <> "Out\n"
      output = Enum.reduce(out_responses, output, fn(response, acc) -> acc <> " - #{response.name}\n" end)
    end
    output
  end

  defp start_roll_call(message) do
    Repo.insert!(%RollCall{chat_id: message.chat.id, status: "open", date: message.date})
  end

  defp close_existing_roll_calls(message) do
    from(r in RollCall, where: r.status == "open", where: r.chat_id == ^message.chat.id)
      |> Repo.update_all(set: [status: "closed"])
  end

  defp update_attendance(roll_call, message, status) do
    case Repo.get_by(RollCallResponse, %{ roll_call_id: roll_call.id, user_id: message.from.id }) do
      nil  -> Ecto.Model.build(roll_call, :responses)
      response -> response
    end
    |> RollCallResponse.changeset(%{user_id: message.from.id, name: message.from.first_name, status: status})
    |> Repo.insert_or_update
  end

end
