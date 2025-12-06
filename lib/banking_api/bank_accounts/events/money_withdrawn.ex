defmodule BankingApi.BankAccounts.Events.MoneyWithdrawn do
  @derive Jason.Encoder
  defstruct [:id, :amount, :date]
end
