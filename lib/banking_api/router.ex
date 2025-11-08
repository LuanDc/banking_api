defmodule BankingApi.Router do
  use Commanded.Commands.Router

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  alias BankingApi.Support.Middleware.Validate

  middleware(Validate)

  identify(BankAccount, prefix: "bank-account-", by: :account_number)

  dispatch(OpenBankAccount, to: BankAccount)
end
