defmodule BankingApi.Repo.Migrations.CreateBankAccountsTable do
  use Ecto.Migration

  def change do
    create table(:bank_accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :account_number, :string
      add :balance, :integer, default: 0
      add :status, :string
    end
  end
end
