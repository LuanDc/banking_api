defmodule BankingApi.BankAccounts.Commands.RequestBankAccountOpening do
  defstruct [:request_id, :id, :account_number, :initial_balance, :status]
  use ExConstructor
  use Vex.Struct

  validates(:request_id, uuid: true, presence: [message: "can't be empty"])
  validates(:id, uuid: true)

  validates(:account_number,
    string: true,
    presence: [message: "can't be empty"]
  )

  validates(:initial_balance, number: [greater_than_or_equal_to: 0])

  validates(:status, inclusion: ["active", "inactive"])

  def assign_id(%__MODULE__{} = command, id) do
    %__MODULE__{command | id: id}
  end
end
