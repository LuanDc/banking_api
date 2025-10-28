defmodule BankingApi.BankAccounts.Supervisor do
  use Supervisor

  alias BankingApi.BankAccounts.Projectors.BankAccount

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        BankAccount
      ],
      strategy: :one_for_one
    )
  end
end
