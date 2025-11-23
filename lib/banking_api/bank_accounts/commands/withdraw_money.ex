defmodule BankingApi.BankAccounts.Commands.WithdrawMoney do
  defstruct [:id, :account_number, :amount]
  use ExConstructor
  use Vex.Struct

  validates(:account_number,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:amount,
    presence: [message: "can't be empty"],
    number: [greater_than_or_equal_to: 0]
  )
end
