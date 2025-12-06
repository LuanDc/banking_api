defmodule BankingApi.BankAccounts.Events.MoneyDeposited do
  @derive Jason.Encoder
  defstruct [:id, :amount, :date]
end
