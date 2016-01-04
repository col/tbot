defmodule Tbot.RollCallResponse do
  use Tbot.Web, :model

  schema "roll_call_responses" do
    field :status, :string
    field :name, :string
    field :user_id, :integer
    belongs_to :roll_call, Tbot.RollCall

    timestamps
  end

  @required_fields ~w(status name user_id)
  @optional_fields ~w()

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
