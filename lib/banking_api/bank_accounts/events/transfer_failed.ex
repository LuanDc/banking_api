defmodule BankingApi.BankAccounts.Events.TransferFailed do
  @derive Jason.Encoder
  defstruct [:id, :request_id, :from_account_id, :error_reason, :date]
end
