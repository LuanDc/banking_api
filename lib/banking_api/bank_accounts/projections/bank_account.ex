defmodule BankingApi.BankAccounts.Projections.BankAccount do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Jason.Encoder, except: [:__meta__]}
  schema "bank_accounts" do
    field :account_number, :string
    field :balance, :integer
    field :status, Ecto.Enum, values: [:active, :inactive]
  end
end
