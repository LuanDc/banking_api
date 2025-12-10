defmodule BankingApi.BankAccounts.Events.BankAccountOpeningRequested do
  @derive Jason.Encoder
  defstruct [:id, :request_id, :account_number, :initial_balance, :status, :request_status, :date]
end
