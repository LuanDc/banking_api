defmodule BankingApi.Router do
  use Commanded.Commands.Router

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus

  alias BankingApi.Support.Middleware.Validate

  middleware(Validate)

  identify(BankAccount, prefix: "bank-account-", by: &__MODULE__.identity/1)

  dispatch(
    [
      OpenBankAccount,
      DepositMoney,
      WithdrawMoney,
      UpdateBankAccountStatus
    ],
    to: BankAccount
  )

  def identity(%OpenBankAccount{id: id}), do: id
  def identity(%DepositMoney{bank_account_id: id}), do: id
  def identity(%WithdrawMoney{bank_account_id: id}), do: id
  def identity(%UpdateBankAccountStatus{bank_account_id: id}), do: id
end
