defmodule BankingApi.BankAccounts.Events.BankAccountOpened do
  @derive Jason.Encoder
  defstruct [:id, :account_number, :balance, :status]
end
