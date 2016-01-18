defmodule Tbot.Message do
  alias Tbot.RollCall

  def add_command(message = %{ text: text }) do
    command = String.split(text) |> List.first |> String.slice(1..-1)
    if String.contains?(command, "@") do
      {command, _} = String.split(command, "@") |> List.to_tuple
    end

    Map.put(message, :command, String.to_atom(command))
  end

  def add_command(message) do
    message
  end

  def add_params(message = %{ text: text }) do
    params = String.split(text) |> List.delete_at(0)
    Map.put(message, :params, params)
  end

  def add_params(message) do
    message
  end

  def add_existing_roll_call(message) do
    roll_call = RollCall.roll_call_for_message(message)
    Map.put(message, :roll_call, roll_call)
  end

  def requires_roll_call?(message = %{ command: command }) do
    command != :start_roll_call
  end

  def requires_roll_call?(_) do
    false
  end

  def roll_call_not_found?(message) do
    message.roll_call == nil
  end

end
