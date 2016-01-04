defmodule Tbot.RollCallTest do
  use Tbot.ModelCase

  alias Tbot.RollCall

  @valid_attrs %{chat_id: 42, date: "2010-04-17 14:00:00", status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RollCall.changeset(%RollCall{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RollCall.changeset(%RollCall{}, @invalid_attrs)
    refute changeset.valid?
  end
end