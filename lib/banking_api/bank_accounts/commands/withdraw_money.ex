defmodule BankingApi.BankAccounts.Commands.WithdrawMoney do
  defstruct [:bank_account_id, :amount]
  use ExConstructor
  use Vex.Struct

  validates(:bank_account_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:amount,
    presence: [message: "can't be empty"],
    number: [greater_than_or_equal_to: 0]
  )
end
