defmodule BankingApi.BankAccounts.Aggregates.AccountNumberReservationTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Aggregates.AccountNumberReservation
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Events.AccountNumberReserved
  alias BankingApi.BankAccounts.Events.AccountNumberReservationFailed

  describe "execute/2 - ReserveAccountNumber" do
    test "creates AccountNumberReserved event when account number is not reserved" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()
      account_number = "RES-001"

      command = %ReserveAccountNumber{
        bank_account_id: bank_account_id,
        account_number: account_number,
        request_id: request_id
      }

      aggregate = %AccountNumberReservation{account_number: nil}

      event = AccountNumberReservation.execute(aggregate, command)

      assert %AccountNumberReserved{
               bank_account_id: ^bank_account_id,
               account_number: ^account_number,
               request_id: ^request_id
             } = event

      assert %DateTime{} = event.date
    end

    test "returns AccountNumberReservationFailed event when account number is already reserved" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()
      account_number = "RES-002"

      command = %ReserveAccountNumber{
        bank_account_id: bank_account_id,
        account_number: account_number,
        request_id: request_id
      }

      aggregate = %AccountNumberReservation{
        bank_account_id: bank_account_id,
        account_number: account_number,
        date: DateTime.utc_now()
      }

      event = AccountNumberReservation.execute(aggregate, command)

      assert %AccountNumberReservationFailed{
               bank_account_id: ^bank_account_id,
               account_number: ^account_number,
               request_id: ^request_id,
               error_reason: :account_number_already_reserved
             } = event

      assert %DateTime{} = event.date
    end
  end

  describe "apply/2 - AccountNumberReserved" do
    test "updates aggregate state with reservation data" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()
      account_number = "RES-003"
      date = DateTime.utc_now()

      event = %AccountNumberReserved{
        bank_account_id: bank_account_id,
        account_number: account_number,
        request_id: request_id,
        date: date
      }

      aggregate = %AccountNumberReservation{account_number: nil}

      result = AccountNumberReservation.apply(aggregate, event)

      assert %AccountNumberReservation{
               bank_account_id: ^bank_account_id,
               account_number: ^account_number,
               date: ^date
             } = result
    end
  end
end
