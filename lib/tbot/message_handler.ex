defmodule Tbot.MessageHandler do
  import Ecto.Query, only: [from: 2]
  alias Tbot.Repo
  alias Tbot.RollCall
  alias Tbot.RollCallResponse

  def handle_message(message = %{text: text}) when text == "/start_roll_call" do
    close_existing_roll_calls(message)
    start_roll_call(message)
    {:ok, "Roll call started"}
  end

  def handle_message(message = %{text: text}) when text == "/end_roll_call" do
    close_existing_roll_calls(message)
    {:ok, "Roll call ended"}
  end

  def handle_message(message = %{text: text}) when text == "/in" do
      update_attendance(message, "in")
      {:ok, "#{message.from.first_name} is in!"}
  end

  def handle_message(message = %{text: text}) when text == "/out" do
      update_attendance(message, "out")
      {:ok, "#{message.from.first_name} is out!"}
  end

  def handle_message(message = %{text: text}) when text == "/whos_in" do
    roll_call = Repo.get_by!(RollCall, %{chat_id: message.chat.id, status: "open"})
    |> Repo.preload(:responses)

    output = roll_call.responses
    |> Enum.filter(fn r -> r.status == "in" end)
    |> Enum.with_index
    |> Enum.reduce("", fn({response, index}, acc) -> acc <> "#{index+1}. #{response.name}\n" end)

    output = output <> "\nOut\n"

    output = roll_call.responses
    |> Enum.filter(fn r -> r.status == "out" end)
    |> Enum.reduce(output, fn(response, acc) -> acc <> " - #{response.name}\n" end)

    {:ok, output}
  end

  def handle_message(message)do
    {:error, "Unknown message: #{to_string(message)}"}
  end

  defp start_roll_call(message) do
    Repo.insert!(%RollCall{chat_id: message.chat.id, status: "open", date: message.date})
  end

  defp close_existing_roll_calls(message) do
    from(r in RollCall, where: r.status == "open", where: r.chat_id == ^message.chat.id)
      |> Repo.update_all(set: [status: "closed"])
  end

  defp update_attendance(message, status) do
    Repo.get_by!(RollCall, %{chat_id: message.chat.id, status: "open"})
    |> Ecto.Model.build(:responses, %{user_id: message.from.id, name: message.from.first_name, status: status})
    |> Repo.insert!
  end

end
