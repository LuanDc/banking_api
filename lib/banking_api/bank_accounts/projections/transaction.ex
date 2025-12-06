defmodule BankingApi.BankAccounts.Projections.Transaction do
  use Ecto.Schema

  alias BankingApi.BankAccounts.Projections.BankAccount

  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Jason.Encoder, except: [:__meta__, :bank_account]}
  schema "transactions" do
    field :account_number, :string
    field :type, :string
    field :amount, :integer
    field :date, :utc_datetime_usec

    belongs_to :bank_account, BankAccount, type: :binary_id
  end
end
