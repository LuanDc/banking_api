defmodule BankingApi.BankAccounts.Events.BankAccountOpeningRequested do
  @derive Jason.Encoder
  defstruct [:id, :account_number, :initial_balance, :status, :date]
end
