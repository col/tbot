defmodule Tbot.LibCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Tbot.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Tbot.Repo, [])
    end

    {:ok, %{}}
  end

end
