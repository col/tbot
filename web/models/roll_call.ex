defmodule Tbot.RollCall do
  use Tbot.Web, :model
  alias Tbot.Repo
  alias Tbot.RollCallResponse

  schema "roll_calls" do
    field :chat_id, :integer
    field :date, :integer
    field :status, :string
    field :title, :string
    has_many :responses, Tbot.RollCallResponse

    timestamps
  end

  @required_fields ~w(chat_id status)
  @optional_fields ~w(date title)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def has_title?(roll_call) do
    roll_call.title != nil && String.length(roll_call.title) > 0
  end

  def roll_call_for_message(message) do
    roll_call = Repo.get_by(Tbot.RollCall, %{chat_id: Map.get(message.chat, :id, -1), status: "open"})
    if roll_call != nil do
      Repo.preload(roll_call, :responses)
    end
    roll_call
  end

  def create_roll_call(message) do
    changeset(%Tbot.RollCall{}, %{
      chat_id: message.chat.id,
      status: "open",
      date: message.date,
      title: Enum.join(message.params, " ")
    }) |> Repo.insert!
  end

  def close_existing_roll_calls(message) do
    from(r in Tbot.RollCall, where: r.status == "open", where: r.chat_id == ^message.chat.id)
      |> Repo.update_all(set: [status: "closed"])
  end

  def update_attendance(message, status) do
    case Repo.get_by(RollCallResponse, %{ roll_call_id: message.roll_call.id, user_id: message.from.id }) do
      nil  -> Ecto.Model.build(message.roll_call, :responses)
      response -> response
    end
    |> RollCallResponse.changeset(%{user_id: message.from.id, name: message.from.first_name, status: status, reason: Enum.join(message.params, " ")})
    |> Repo.insert_or_update
  end

  def set_title(roll_call, title) do
    changeset(roll_call, %{title: title}) |> Repo.update!
  end

  def whos_in_list(roll_call) do
    output = []

    if has_title?(roll_call) do
      output = [roll_call.title]
    end

    in_list = in_response_list(roll_call)
    if String.length(in_list) > 0 do
      output = output ++ [in_list]
    end

    maybe_list = maybe_response_list(roll_call)
    if String.length(maybe_list) > 0 do
      output = output ++ [maybe_list]
    end

    out_list = out_response_list(roll_call)
    if String.length(out_list) > 0 do
      output = output ++ [out_list]
    end

    Enum.join(output, "\n")
  end

  defp in_response_list(roll_call) do
    output = ""
    in_responses = RollCallResponse |> RollCallResponse.for_roll_call(roll_call) |> RollCallResponse.with_status("in") |> Repo.all
    unless Enum.empty?(in_responses) do
      output = Enum.with_index(in_responses)
      |> Enum.reduce("", fn({response, index}, acc) -> acc <> "#{index+1}. #{response.name}\n" end)
    end
    output
  end

  defp out_response_list(roll_call) do
    output = ""
    out_responses = RollCallResponse |> RollCallResponse.for_roll_call(roll_call) |> RollCallResponse.with_status("out") |> Repo.all
    unless Enum.empty?(out_responses) do
      output = output <> "Out\n"
      output = Enum.reduce(out_responses, output, fn(response, acc) -> acc <> response_to_string(response) end)
    end
    output
  end

  defp maybe_response_list(roll_call) do
    output = ""
    maybe_responses = RollCallResponse |> RollCallResponse.for_roll_call(roll_call) |> RollCallResponse.with_status("maybe") |> Repo.all
    unless Enum.empty?(maybe_responses) do
      output = output <> "Maybe\n"
      output = Enum.reduce(maybe_responses, output, fn(response, acc) -> acc <> response_to_string(response) end)
    end
    output
  end

  defp response_to_string(response = %{reason: reason}) do
    if reason != nil && String.length(reason) > 0 do
      " - #{response.name} (#{reason})\n"
    else
      " - #{response.name}\n"
    end
  end

end
