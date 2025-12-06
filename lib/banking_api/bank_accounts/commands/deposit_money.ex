defmodule BankingApi.BankAccounts.Commands.DepositMoney do
  defstruct [:id, :amount]
  use ExConstructor
  use Vex.Struct

  validates(:id, uuid: true)
  validates(:amount, number: [greater_than_or_equal_to: 0])
end
