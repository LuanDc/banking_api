defmodule BankingApi.BankAccounts.Events.BankAccountStatusUpdated do
  @derive Jason.Encoder
  defstruct [:bank_account_id, :status]
end
