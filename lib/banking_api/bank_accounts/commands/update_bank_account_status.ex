defmodule BankingApi.BankAccounts.Commands.UpdateBankAccountStatus do
  defstruct [:account_number, :status]
  use ExConstructor
  use Vex.Struct

  validates(:account_number,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:status, inclusion: ["active", "inactive"])
end
