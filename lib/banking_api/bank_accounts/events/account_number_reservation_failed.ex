defmodule BankingApi.BankAccounts.Events.AccountNumberReservationFailed do
  @derive Jason.Encoder
  defstruct [
    :id,
    :bank_account_id,
    :request_id,
    :account_number,
    :error_reason,
    :date
  ]
end
