defmodule BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsCompleted do
  defstruct [:request_id]
  use ExConstructor
  use Vex.Struct

  validates(:request_id, uuid: true, presence: [message: "can't be empty"])
end
