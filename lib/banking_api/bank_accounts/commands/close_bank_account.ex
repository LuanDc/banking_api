defmodule BankingApi.BankAccounts.Commands.CloseBankAccount do
  defstruct [:id]
  use ExConstructor
  use Vex.Struct

  validates(:id,
    presence: [message: "can't be empty"],
    uuid: true
  )
end
