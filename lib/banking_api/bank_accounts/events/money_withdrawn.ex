defmodule BankingApi.BankAccounts.Events.MoneyWithdrawn do
  @derive Jason.Encoder
  defstruct [:id, :account_number, :amount]
end
