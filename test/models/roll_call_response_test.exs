defmodule Tbot.RollCallResponseTest do
  use Tbot.ModelCase

  alias Tbot.RollCallResponse

  @valid_attrs %{name: "some content", status: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RollCallResponse.changeset(%RollCallResponse{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RollCallResponse.changeset(%RollCallResponse{}, @invalid_attrs)
    refute changeset.valid?
  end
end
