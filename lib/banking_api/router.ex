defmodule BankingApi.Router do
  use Commanded.Commands.Router

  alias BankingApi.BankAccounts.Aggregates.AccountNumberReservation
  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest

  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.RequestBankAccountOpening
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus
  alias BankingApi.BankAccounts.Commands.WithdrawMoney

  alias BankingApi.Support.Middleware.Validate

  middleware(Validate)

  identify(BankAccount, prefix: "bank-account-", by: &__MODULE__.identity/1)

  identify(AccountNumberReservation,
    prefix: "account-number-reservation-",
    by: &__MODULE__.identity/1
  )

  identify(BankAccountOpeningRequest,
    prefix: "bank-account-opening-request-",
    by: :request_id
  )

  dispatch([RequestBankAccountOpening, MarkBankAccountOpeningAsFailed],
    to: BankAccountOpeningRequest
  )

  dispatch(
    [
      OpenBankAccount,
      DepositMoney,
      WithdrawMoney,
      UpdateBankAccountStatus
    ],
    to: BankAccount
  )

  dispatch(ReserveAccountNumber, to: AccountNumberReservation)

  def identity(%OpenBankAccount{id: id}), do: id
  def identity(%DepositMoney{bank_account_id: id}), do: id
  def identity(%WithdrawMoney{bank_account_id: id}), do: id
  def identity(%UpdateBankAccountStatus{bank_account_id: id}), do: id
  def identity(%ReserveAccountNumber{account_number: account_number}), do: account_number
end
