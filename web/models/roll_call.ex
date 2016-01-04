defmodule Tbot.RollCall do
  use Tbot.Web, :model

  schema "roll_calls" do
    field :chat_id, :integer
    field :date, :integer
    field :status, :string
    has_many :responses, Tbot.RollCallResponse

    timestamps
  end

  @required_fields ~w(chat_id status)
  @optional_fields ~w(date)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
