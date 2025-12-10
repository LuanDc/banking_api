defmodule BankingApi.BankAccounts.Events.AccountNumberReserved do
  @derive Jason.Encoder
  defstruct [:bank_account_id, :account_number, :date]
end
