defmodule BankingApi.BankAccounts.Aggregates.AccountNumberReservationTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Aggregates.AccountNumberReservation
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Events.AccountNumberReserved

  describe "execute/2 - ReserveAccountNumber" do
    test "creates AccountNumberReserved event when account number is not reserved" do
      bank_account_id = Ecto.UUID.generate()
      account_number = "RES-001"

      command = %ReserveAccountNumber{
        bank_account_id: bank_account_id,
        account_number: account_number
      }

      aggregate = %AccountNumberReservation{account_number: nil}

      event = AccountNumberReservation.execute(aggregate, command)

      assert %AccountNumberReserved{
               bank_account_id: ^bank_account_id,
               account_number: ^account_number
             } = event

      assert %DateTime{} = event.date
    end

    test "returns error when account number is already reserved" do
      bank_account_id = Ecto.UUID.generate()
      account_number = "RES-002"

      command = %ReserveAccountNumber{
        bank_account_id: bank_account_id,
        account_number: account_number
      }

      aggregate = %AccountNumberReservation{
        bank_account_id: bank_account_id,
        account_number: account_number,
        date: DateTime.utc_now()
      }

      assert {:error, :account_number_already_reserved} =
               AccountNumberReservation.execute(aggregate, command)
    end
  end

  describe "apply/2 - AccountNumberReserved" do
    test "updates aggregate state with reservation data" do
      bank_account_id = Ecto.UUID.generate()
      account_number = "RES-003"
      date = DateTime.utc_now()

      event = %AccountNumberReserved{
        bank_account_id: bank_account_id,
        account_number: account_number,
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
