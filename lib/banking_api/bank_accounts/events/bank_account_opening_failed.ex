defmodule BankingApi.BankAccounts.Events.BankAccountOpeningFailed do
  @derive Jason.Encoder
  defstruct [
    :id,
    :error_reason,
    :date
  ]
end
