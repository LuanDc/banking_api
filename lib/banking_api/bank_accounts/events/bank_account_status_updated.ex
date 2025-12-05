defmodule BankingApi.BankAccounts.Events.BankAccountStatusUpdated do
  @derive Jason.Encoder
  defstruct [:account_number, :status]
end
