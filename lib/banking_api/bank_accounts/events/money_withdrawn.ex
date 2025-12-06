defmodule BankingApi.BankAccounts.Events.MoneyWithdrawn do
  @derive Jason.Encoder
  defstruct [:bank_account_id, :amount, :date]
end
