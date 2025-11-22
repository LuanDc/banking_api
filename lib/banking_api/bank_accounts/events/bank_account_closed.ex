defmodule BankingApi.BankAccounts.Events.BankAccountClosed do
  @derive Jason.Encoder
  defstruct [:account_number, :status]
end
