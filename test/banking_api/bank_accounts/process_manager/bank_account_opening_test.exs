defmodule BankingApi.BankAccounts.ProcessManager.BankAccountOpeningTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Events.AccountNumberReserved
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested
  alias BankingApi.BankAccounts.ProcessManager.BankAccountOpening

  describe "interested?/1" do
    test "starts process on BankAccountOpeningRequested event" do
      id = Ecto.UUID.generate()
      event = %BankAccountOpeningRequested{id: id, account_number: "PM-001"}

      assert {:start, ^id} = BankAccountOpening.interested?(event)
    end

    test "stops process on AccountNumberReserved event" do
      bank_account_id = Ecto.UUID.generate()
      event = %AccountNumberReserved{bank_account_id: bank_account_id, account_number: "PM-001"}

      assert {:stop, ^bank_account_id} = BankAccountOpening.interested?(event)
    end
  end

  describe "handle/2 - BankAccountOpeningRequested" do
    test "dispatches ReserveAccountNumber command" do
      id = Ecto.UUID.generate()
      account_number = "PM-002"

      event = %BankAccountOpeningRequested{
        id: id,
        account_number: account_number,
        initial_balance: 1000,
        status: "active",
        date: DateTime.utc_now()
      }

      state = %BankAccountOpening{}

      commands = BankAccountOpening.handle(state, event)

      assert [
               %ReserveAccountNumber{
                 bank_account_id: ^id,
                 account_number: ^account_number
               }
             ] = commands
    end
  end

  describe "handle/2 - AccountNumberReserved" do
    test "dispatches OpenBankAccount command with stored state" do
      bank_account_id = Ecto.UUID.generate()
      account_number = "PM-003"

      state = %BankAccountOpening{
        account_number: account_number,
        initial_balance: 2000,
        status: "inactive"
      }

      event = %AccountNumberReserved{
        bank_account_id: bank_account_id,
        account_number: account_number,
        date: DateTime.utc_now()
      }

      command = BankAccountOpening.handle(state, event)

      assert %OpenBankAccount{
               id: ^bank_account_id,
               account_number: ^account_number,
               initial_balance: 2000,
               status: "inactive"
             } = command
    end
  end

  describe "apply/2" do
    test "stores initial_balance and status from BankAccountOpeningRequested" do
      event = %BankAccountOpeningRequested{
        id: Ecto.UUID.generate(),
        account_number: "PM-004",
        initial_balance: 3000,
        status: "active",
        date: DateTime.utc_now()
      }

      state = %BankAccountOpening{}

      result = BankAccountOpening.apply(state, event)

      assert %BankAccountOpening{
               account_number: "PM-004",
               initial_balance: 3000,
               status: "active"
             } = result
    end

    test "maintains state on AccountNumberReserved" do
      state = %BankAccountOpening{
        account_number: "PM-005",
        initial_balance: 1500,
        status: "inactive"
      }

      event = %AccountNumberReserved{
        bank_account_id: Ecto.UUID.generate(),
        account_number: "PM-005",
        date: DateTime.utc_now()
      }

      result = BankAccountOpening.apply(state, event)

      assert result == state
    end
  end

  describe "error/3" do
    test "skips processing on account_number_already_reserved error" do
      error = {:error, :account_number_already_reserved}
      command = %ReserveAccountNumber{}
      failure_context = %{context: %{failures: 0}}

      assert :skip = BankAccountOpening.error(error, command, failure_context)
    end

    test "stops after too many failures" do
      error = {:error, :some_error}
      command = %ReserveAccountNumber{}
      failure_context = %{context: %{failures: 2}}

      assert {:stop, :too_many_failures} = BankAccountOpening.error(error, command, failure_context)
    end

    test "skips on unknown errors" do
      error = {:error, :unknown_error}
      command = %ReserveAccountNumber{}
      failure_context = %{context: %{failures: 0}}

      assert :skip = BankAccountOpening.error(error, command, failure_context)
    end
  end
end
