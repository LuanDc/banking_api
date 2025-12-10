defmodule BankingApi.Repo.Migrations.CreateBankAccountOpeningRequestsTable do
  use Ecto.Migration

  def change do
    create table(:bank_account_opening_requests, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :account_number, :string, null: false
      add :initial_balance, :integer, null: false
      add :status, :string, null: false
      add :request_status, :string, null: false
      add :error, :string
      add :requested_at, :utc_datetime_usec, null: false
    end

    create index(:bank_account_opening_requests, [:account_number])
    create index(:bank_account_opening_requests, [:request_status])
  end
end
