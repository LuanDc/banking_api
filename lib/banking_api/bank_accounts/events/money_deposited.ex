defmodule BankingApi.BankAccounts.Events.MoneyDeposited do
  @derive Jason.Encoder
  defstruct [:id, :account_number, :amount]
end
