defmodule BankingApi.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :bank_account_id, references(:bank_accounts, type: :uuid, on_delete: :delete_all),
        null: false
      add :account_number, :string, null: false
      add :type, :string, null: false
      add :amount, :integer, null: false
      add :date, :utc_datetime_usec, null: false
    end

    create index(:transactions, [:bank_account_id])
    create index(:transactions, [:account_number])
    create index(:transactions, [:date])
  end
end
