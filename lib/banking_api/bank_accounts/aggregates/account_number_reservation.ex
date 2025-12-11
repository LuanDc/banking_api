defmodule BankingApi.BankAccounts.Aggregates.AccountNumberReservation do
  defstruct [:bank_account_id, :account_number, :date]

  alias BankingApi.BankAccounts.Aggregates.AccountNumberReservation
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Events.AccountNumberReserved
  alias BankingApi.BankAccounts.Events.AccountNumberReservationFailed

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  @impl Aggregate
  def execute(
        %AccountNumberReservation{account_number: nil},
        %ReserveAccountNumber{
          bank_account_id: bank_account_id,
          account_number: account_number,
          request_id: request_id
        }
      ) do
    %AccountNumberReserved{
      bank_account_id: bank_account_id,
      account_number: account_number,
      request_id: request_id,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%AccountNumberReservation{}, %ReserveAccountNumber{
        bank_account_id: bank_account_id,
        account_number: account_number,
        request_id: request_id
      }) do
    %AccountNumberReservationFailed{
      bank_account_id: bank_account_id,
      account_number: account_number,
      request_id: request_id,
      error_reason: :account_number_already_reserved,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def apply(%AccountNumberReservation{} = reservation, %AccountNumberReserved{} = event) do
    %AccountNumberReserved{
      bank_account_id: bank_account_id,
      account_number: account_number,
      date: date
    } = event

    %AccountNumberReservation{
      reservation
      | bank_account_id: bank_account_id,
        account_number: account_number,
        date: date
    }
  end

  @impl Aggregate
  def apply(%AccountNumberReservation{} = reservation, %AccountNumberReservationFailed{}) do
    reservation
  end
end
