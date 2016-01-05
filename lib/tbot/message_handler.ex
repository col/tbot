defmodule Tbot.MessageHandler do
  import Tbot.Message
  alias Tbot.RollCall

  def start_roll_call_command(message) do
    RollCall.close_existing_roll_calls(message)
    RollCall.create_roll_call(message)
    if length(message.params) > 0 do
      {:ok, "#{Enum.join(message.params, " ")} roll call started"}
    else
      {:ok, "Roll call started"}
    end
  end

  def end_roll_call_command(message) do
    RollCall.close_existing_roll_calls(message)
    {:ok, "Roll call ended"}
  end

  def in_command(message) do
    RollCall.update_attendance(message, "in")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def out_command(message) do
    RollCall.update_attendance(message, "out")
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def whos_in_command(message) do
    {:ok, RollCall.whos_in_list(message.roll_call)}
  end

  def handle_message(message) do
    message = message
    |> add_command
    |> add_params
    |> add_existing_roll_call

    if valid_command?(message) do
      if requires_roll_call?(message) && roll_call_not_found?(message) do
        {:ok, "No roll call in progress"}
      else
        execute_command(message)
      end
    end
  end

  defp execute_command(message) do
    try do
      apply(Tbot.MessageHandler, message.command, [message])
    rescue UndefinedFunctionError ->
      {:error, "Unknown command: #{to_string(message.command)}"}
    end
  end

end
