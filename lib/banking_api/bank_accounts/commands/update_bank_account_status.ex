defmodule BankingApi.BankAccounts.Commands.UpdateBankAccountStatus do
  defstruct [:id, :status]
  use ExConstructor
  use Vex.Struct

  validates(:id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:status, inclusion: ["active", "inactive"])
end
