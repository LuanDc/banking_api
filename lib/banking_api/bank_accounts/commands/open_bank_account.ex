defmodule BankingApi.BankAccounts.Commands.OpenBankAccount do
  defstruct [:id, :account_number, :initial_balance, :status]
  use ExConstructor
  use Vex.Struct

  validates(:id, uuid: true)

  validates(:account_number,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:initial_balance,
    presence: [message: "can't be empty"],
    number: [greater_than_or_equal_to: 0]
  )

  validates(:status,
    presence: [message: "can't be empty"],
    inclusion: ["open", "closed"]
  )

  def assign_id(%__MODULE__{} = open_bank_account, id) do
    %__MODULE__{open_bank_account | id: id}
  end
end
