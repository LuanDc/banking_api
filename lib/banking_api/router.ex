defmodule BankingApi.Router do
  use Commanded.Commands.Router

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus

  alias BankingApi.Support.Middleware.Validate

  middleware(Validate)

  identify(BankAccount, prefix: "bank-account-", by: :account_number)

  dispatch(
    [
      OpenBankAccount,
      CloseBankAccount,
      DepositMoney,
      WithdrawMoney,
      UpdateBankAccountStatus
    ],
    to: BankAccount
  )
end
