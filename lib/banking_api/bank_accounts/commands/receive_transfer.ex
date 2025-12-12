defmodule BankingApi.BankAccounts.Commands.ReceiveTransfer do
  defstruct [:id, :from_account_id, :to_account_id, :amount]
  use ExConstructor
  use Vex.Struct

  validates(:id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:from_account_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:to_account_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:amount,
    presence: [message: "can't be empty"],
    number: [greater_than: 0]
  )
end
