defmodule BankingApi.BankAccounts.Events.TransferInitiated do
  @derive Jason.Encoder
  defstruct [:id, :request_id, :from_account_id, :to_account_id, :amount, :status, :date]
end
