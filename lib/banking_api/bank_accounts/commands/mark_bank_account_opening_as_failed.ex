defmodule BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed do
  defstruct [
    :request_id,
    :error_reason
  ]

  use Vex.Struct
end
