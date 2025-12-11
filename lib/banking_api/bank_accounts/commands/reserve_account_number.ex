defmodule BankingApi.BankAccounts.Commands.ReserveAccountNumber do
  defstruct [:bank_account_id, :account_number, :request_id]
  use ExConstructor
  use Vex.Struct

  validates(:bank_account_id, uuid: true)
  validates(:account_number, string: true, presence: [message: "can't be empty"])
  validates(:request_id, uuid: true)
end
