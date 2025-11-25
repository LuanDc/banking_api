defmodule BankingApi.BankAccounts.Events.MoneyDeposited do
  @derive Jason.Encoder
  defstruct [:account_number, :amount]
end
