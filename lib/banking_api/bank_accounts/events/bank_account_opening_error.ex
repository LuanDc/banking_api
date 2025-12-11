defmodule BankingApi.BankAccounts.Events.BankAccountOpeningError do
  @derive Jason.Encoder
  defstruct [
    :request_id,
    :error_reason,
    :date
  ]
end
