defmodule BankingApi.BankAccounts.Events.BankAccountOpeningFailed do
  @derive Jason.Encoder
  defstruct [
    :request_id,
    :error_reason,
    :date
  ]
end
