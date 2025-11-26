defmodule BankingApi.Factory do
  use ExMachina.Ecto, repo: BankingApi.Repo

  alias BankingApi.BankAccounts.Projections.BankAccount

  def bank_account_factory do
    %BankAccount{
      id: "1f430bb5-81fc-4de3-8c8f-e3fc00adf896",
      account_number: "Jane Smith",
      balance: 0,
      status: :open
    }
  end
end
