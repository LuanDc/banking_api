defmodule BankingApi.BankAccounts.Commands.UpdateBankAccountStatus do
  defstruct [:bank_account_id, :status]
  use ExConstructor
  use Vex.Struct

  validates(:bank_account_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:status, inclusion: ["active", "inactive"])
end
