defmodule BankingApi.Router do
  use Commanded.Commands.Router

  alias BankingApi.BankAccounts.Aggregates.AccountNumberReservation
  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest
  alias BankingApi.BankAccounts.Aggregates.Transfer

  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed
  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsCompleted
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.RequestBankAccountOpening
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.InitiateTransfer
  alias BankingApi.BankAccounts.Commands.CompleteTransfer
  alias BankingApi.BankAccounts.Commands.ReceiveTransfer

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

  identify(Transfer,
    prefix: "transfer-",
    by: :request_id
  )

  dispatch(
    [
      RequestBankAccountOpening,
      MarkBankAccountOpeningAsFailed,
      MarkBankAccountOpeningAsCompleted
    ],
    to: BankAccountOpeningRequest
  )

  dispatch(
    [
      OpenBankAccount,
      DepositMoney,
      WithdrawMoney,
      UpdateBankAccountStatus,
      CompleteTransfer,
      ReceiveTransfer
    ],
    to: BankAccount
  )

  dispatch(ReserveAccountNumber, to: AccountNumberReservation)

  dispatch(InitiateTransfer, to: Transfer)

  def identity(%OpenBankAccount{id: id}), do: id
  def identity(%DepositMoney{bank_account_id: id}), do: id
  def identity(%WithdrawMoney{bank_account_id: id}), do: id
  def identity(%UpdateBankAccountStatus{bank_account_id: id}), do: id
  def identity(%CompleteTransfer{from_account_id: id}), do: id
  def identity(%ReceiveTransfer{to_account_id: id}), do: id
  def identity(%ReserveAccountNumber{account_number: account_number}), do: account_number
end
