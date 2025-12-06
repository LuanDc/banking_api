defmodule BankingApi.BankAccounts.Events.MoneyDeposited do
  @derive Jason.Encoder
  defstruct [:bank_account_id, :amount, :date]
end
