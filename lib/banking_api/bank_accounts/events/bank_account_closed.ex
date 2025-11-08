defmodule BankingApi.BankAccounts.Events.BankAccountClosed do
  @derive Jason.Encoder
  defstruct [:id, :account_number]
end
