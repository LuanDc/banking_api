defmodule BankingApi.BankAccounts.Projections.BankAccount do
  use Ecto.Schema

  schema "bank_accounts" do
    field :account_number, :string
    field :balance, :integer
  end
end
