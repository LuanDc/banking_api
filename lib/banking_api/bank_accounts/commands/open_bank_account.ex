defmodule BankingApi.BankAccounts.Commands.OpenBankAccount do
  defstruct [:id, :account_number, :initial_balance, :status]
  use ExConstructor
  use Vex.Struct

  validates(:id, uuid: true)

  validates(:account_number,
    string: true,
    presence: [message: "can't be empty"]
  )

  validates(:initial_balance, number: [greater_than_or_equal_to: 0])

  validates(:status, inclusion: ["active", "inactive"])

  def assign_id(%__MODULE__{} = open_bank_account, id) do
    %__MODULE__{open_bank_account | id: id}
  end
end
