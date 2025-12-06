defmodule BankingApi.BankAccounts.Events.MoneyWithdrawn do
  @derive Jason.Encoder
  defstruct [:account_number, :amount, :date]
end
