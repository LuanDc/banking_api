defmodule BankingApi.BankAccounts.Commands.ReserveAccountNumber do
  defstruct [:bank_account_id, :account_number]
  use ExConstructor
  use Vex.Struct

  validates(:bank_account_id, uuid: true)
  validates(:account_number, string: true, presence: [message: "can't be empty"])
end
