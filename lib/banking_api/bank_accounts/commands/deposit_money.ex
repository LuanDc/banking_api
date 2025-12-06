defmodule BankingApi.BankAccounts.Commands.DepositMoney do
  defstruct [:bank_account_id, :amount]
  use ExConstructor
  use Vex.Struct

  validates(:bank_account_id, uuid: true)
  validates(:amount, number: [greater_than_or_equal_to: 0])
end
