defmodule BankingApi.BankAccounts.Commands.CloseBankAccount do
  defstruct [:account_number]
  use ExConstructor
  use Vex.Struct

  validates(:account_number,
    presence: [message: "can't be empty"],
    string: true
  )
end
