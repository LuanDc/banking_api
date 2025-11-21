defmodule BankingApi.BankAccounts.Events.BankAccountCreated do
  @derive Jason.Encoder
  defstruct [:id, :account_number, :balance]
end
