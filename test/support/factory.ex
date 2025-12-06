defmodule BankingApi.Factory do
  use ExMachina.Ecto, repo: BankingApi.Repo

  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankAccounts.Projections.Transaction

  def bank_account_factory do
    %BankAccount{
      id: Ecto.UUID.generate(),
      account_number: Ecto.UUID.generate(),
      balance: 0,
      status: :active
    }
  end

  def transaction_factory do
    bank_account = insert(:bank_account)

    %Transaction{
      id: Ecto.UUID.generate(),
      bank_account_id: bank_account.id,
      account_number: bank_account.account_number,
      type: "deposit",
      amount: 100,
      date: DateTime.utc_now()
    }
  end
end
