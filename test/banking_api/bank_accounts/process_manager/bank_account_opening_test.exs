defmodule BankingApi.BankAccounts.ProcessManager.BankAccountOpeningTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Events.AccountNumberReserved
  alias BankingApi.BankAccounts.Events.AccountNumberReservationFailed
  alias BankingApi.BankAccounts.Events.BankAccountOpeningError
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested
  alias BankingApi.BankAccounts.ProcessManager.BankAccountOpening

  describe "interested?/1" do
    test "starts process on BankAccountOpeningRequested event" do
      request_id = Ecto.UUID.generate()
      id = Ecto.UUID.generate()

      event = %BankAccountOpeningRequested{
        id: id,
        account_number: "PM-001",
        request_id: request_id
      }

      assert {:start, ^request_id} = BankAccountOpening.interested?(event)
    end

    test "stops process on AccountNumberReserved event" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()

      event = %AccountNumberReserved{
        bank_account_id: bank_account_id,
        account_number: "PM-001",
        request_id: request_id
      }

      assert {:continue, ^request_id} = BankAccountOpening.interested?(event)
    end
  end

  describe "handle/2 - BankAccountOpeningRequested" do
    test "dispatches ReserveAccountNumber command" do
      request_id = Ecto.UUID.generate()
      id = Ecto.UUID.generate()
      account_number = "PM-002"

      event = %BankAccountOpeningRequested{
        id: id,
        account_number: account_number,
        request_id: request_id,
        initial_balance: 1000,
        status: "active",
        date: DateTime.utc_now()
      }

      state = %BankAccountOpening{}

      commands = BankAccountOpening.handle(state, event)

      assert [
               %ReserveAccountNumber{
                 bank_account_id: ^id,
                 account_number: ^account_number,
                 request_id: ^request_id
               }
             ] = commands
    end
  end

  describe "handle/2 - AccountNumberReserved" do
    test "dispatches OpenBankAccount command with stored state" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()
      account_number = "PM-003"

      state = %BankAccountOpening{
        account_number: account_number,
        initial_balance: 2000,
        status: "inactive",
        request_id: request_id
      }

      event = %AccountNumberReserved{
        bank_account_id: bank_account_id,
        account_number: account_number,
        request_id: request_id,
        date: DateTime.utc_now()
      }

      command = BankAccountOpening.handle(state, event)

      assert %OpenBankAccount{
               id: ^bank_account_id,
               account_number: ^account_number,
               initial_balance: 2000,
               status: "inactive",
               request_id: ^request_id
             } = command
    end
  end

  describe "apply/2" do
    test "stores initial_balance and status from BankAccountOpeningRequested" do
      request_id = Ecto.UUID.generate()

      event = %BankAccountOpeningRequested{
        id: Ecto.UUID.generate(),
        account_number: "PM-004",
        request_id: request_id,
        initial_balance: 3000,
        status: "active",
        date: DateTime.utc_now()
      }

      state = %BankAccountOpening{}

      result = BankAccountOpening.apply(state, event)

      assert %BankAccountOpening{
               account_number: "PM-004",
               initial_balance: 3000,
               status: "active",
               request_id: ^request_id
             } = result
    end

    test "maintains state on AccountNumberReserved" do
      request_id = Ecto.UUID.generate()

      state = %BankAccountOpening{
        account_number: "PM-005",
        initial_balance: 1500,
        status: "inactive",
        request_id: request_id
      }

      event = %AccountNumberReserved{
        bank_account_id: Ecto.UUID.generate(),
        account_number: "PM-005",
        request_id: request_id,
        date: DateTime.utc_now()
      }

      result = BankAccountOpening.apply(state, event)

      assert result == state
    end
  end

  describe "handle/2 - AccountNumberReservationFailed" do
    test "dispatches MarkBankAccountOpeningAsFailed command when request_id is present" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()
      error_reason = "Database connection failed"

      state = %BankAccountOpening{
        id: bank_account_id,
        request_id: request_id
      }

      event = %AccountNumberReservationFailed{
        bank_account_id: bank_account_id,
        account_number: "PM-006",
        error_reason: error_reason,
        date: DateTime.utc_now()
      }

      command = BankAccountOpening.handle(state, event)

      assert %MarkBankAccountOpeningAsFailed{
               request_id: ^request_id,
               error_reason: ^error_reason
             } = command
    end

    test "returns empty list when request_id is nil" do
      bank_account_id = Ecto.UUID.generate()

      state = %BankAccountOpening{
        id: bank_account_id,
        request_id: nil
      }

      event = %AccountNumberReservationFailed{
        bank_account_id: bank_account_id,
        account_number: "PM-007",
        error_reason: "Some error",
        date: DateTime.utc_now()
      }

      assert [] = BankAccountOpening.handle(state, event)
    end
  end

  describe "handle/2 - BankAccountOpeningError" do
    test "dispatches MarkBankAccountOpeningAsFailed command when request_id is present" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()
      error_reason = "Validation failed"

      state = %BankAccountOpening{
        id: bank_account_id,
        request_id: request_id
      }

      event = %BankAccountOpeningError{
        request_id: request_id,
        error_reason: error_reason,
        date: DateTime.utc_now()
      }

      command = BankAccountOpening.handle(state, event)

      assert %MarkBankAccountOpeningAsFailed{
               request_id: ^request_id,
               error_reason: ^error_reason
             } = command
    end

    test "returns empty list when request_id is nil" do
      bank_account_id = Ecto.UUID.generate()

      state = %BankAccountOpening{
        id: bank_account_id,
        request_id: nil
      }

      event = %BankAccountOpeningError{
        request_id: Ecto.UUID.generate(),
        error_reason: "Some error",
        date: DateTime.utc_now()
      }

      assert [] = BankAccountOpening.handle(state, event)
    end
  end

  describe "interested?/1 - error events" do
    test "continues process on AccountNumberReservationFailed event" do
      request_id = Ecto.UUID.generate()
      bank_account_id = Ecto.UUID.generate()

      event = %AccountNumberReservationFailed{
        bank_account_id: bank_account_id,
        account_number: "PM-008",
        request_id: request_id,
        error_reason: "Error",
        date: DateTime.utc_now()
      }

      assert {:continue, ^request_id} = BankAccountOpening.interested?(event)
    end

    test "continues process on BankAccountOpeningError event" do
      request_id = Ecto.UUID.generate()

      event = %BankAccountOpeningError{
        request_id: request_id,
        error_reason: "Error",
        date: DateTime.utc_now()
      }

      assert {:continue, ^request_id} = BankAccountOpening.interested?(event)
    end
  end

  describe "error/3" do
    test "skips processing on account_number_already_reserved error" do
      error = {:error, :account_number_already_reserved}
      command = %ReserveAccountNumber{}
      failure_context = %{context: %{failures: 0}}

      assert BankAccountOpening.error(error, command, failure_context) == {:stop, error}
    end

    test "skips on unknown errors" do
      error = {:error, :unknown_error}
      command = %ReserveAccountNumber{}
      failure_context = %{context: %{failures: 0}}

      assert BankAccountOpening.error(error, command, failure_context) == {:stop, error}
    end
  end
end
