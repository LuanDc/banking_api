defmodule BankingApi.BankAccounts.Projections.BankAccountOpeningRequest do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "bank_account_opening_requests" do
    field :account_number, :string
    field :initial_balance, :integer
    field :status, Ecto.Enum, values: [:active, :inactive]
    field :request_status, Ecto.Enum, values: [:in_progress, :completed, :failed]
    field :error, :string
    field :requested_at, :utc_datetime_usec
  end
end
