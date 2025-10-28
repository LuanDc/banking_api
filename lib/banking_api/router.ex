defmodule BankingApi.Router do
  use Commanded.Commands.Router

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  dispatch(OpenBankAccount, to: BankAccount, identity: :account_number)
end
