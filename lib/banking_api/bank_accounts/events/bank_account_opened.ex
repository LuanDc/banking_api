defmodule BankingApi.BankAccounts.Events.BankAccountOpened do
  @derive Jason.Encoder
  defstruct [:id, :account_number, :status, :request_id, :initial_balance, :date]
end
