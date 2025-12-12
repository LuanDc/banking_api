defmodule BankingApi.BankAccounts.Events.TransferReceived do
  @derive Jason.Encoder
  defstruct [:id, :from_account_id, :to_account_id, :amount, :date]
end
