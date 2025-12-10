defmodule BankingApi.BankAccounts.Events.BankAccountOpeningCompleted do
  @derive Jason.Encoder
  defstruct [:request_id, :bank_account_id, :date]
end
