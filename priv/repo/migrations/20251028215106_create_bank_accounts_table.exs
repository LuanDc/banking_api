defmodule BankingApi.Repo.Migrations.CreateBankAccountsTable do
  use Ecto.Migration

  def change do
    create table("bank_accounts") do
      add :account_number, :string
      add :balance, :integer
    end
  end
end
