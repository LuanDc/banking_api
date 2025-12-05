defmodule BankingApi.Factory do
  use ExMachina.Ecto, repo: BankingApi.Repo

  alias BankingApi.BankAccounts.Projections.BankAccount

  def bank_account_factory do
    %BankAccount{
      id: Ecto.UUID.generate(),
      account_number: "Jane Smith",
      balance: 0,
      status: :active
    }
  end
end
