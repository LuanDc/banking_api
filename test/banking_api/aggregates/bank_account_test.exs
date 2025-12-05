defmodule BankingApi.Aggregates.BankAccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.{
    OpenBankAccount,
    DepositMoney,
    WithdrawMoney,
    CloseBankAccount
  }

  alias BankingApi.BankAccounts.Events.{
    BankAccountOpened,
    BankAccountClosed,
    MoneyDeposited,
    MoneyWithdrawn
  }

  describe "BankAccount.execute/2 - OpenBankAccount" do
    @tag :unit
    test "returns BankAccountOpened event when account is not initialized" do
      # ARRANGE
      aggregate = %BankAccount{account_number: nil}

      command = %OpenBankAccount{
        id: "550e8400-e29b-41d4-a716-446655440000",
        account_number: "ACC-001",
        initial_balance: 1000,
        status: "active"
      }

      # ACT
      result = BankAccount.execute(aggregate, command)

      # ASSERT
      assert result == %BankAccountOpened{
               id: "550e8400-e29b-41d4-a716-446655440000",
               account_number: "ACC-001",
               initial_balance: 1000,
               status: "active"
             }
    end

    @tag :unit
    test "returns BankAccountOpened event with zero balance when initial_balance not provided" do
      aggregate = %BankAccount{account_number: nil}

      command = %OpenBankAccount{
        id: "550e8400-e29b-41d4-a716-446655440001",
        account_number: "ACC-002",
        initial_balance: 0,
        status: "active"
      }

      result = BankAccount.execute(aggregate, command)

      assert result == %BankAccountOpened{
               id: "550e8400-e29b-41d4-a716-446655440001",
               account_number: "ACC-002",
               initial_balance: 0,
               status: "active"
             }
    end

    @tag :unit
    test "returns error when account already has an id (already opened)" do
      aggregate = %BankAccount{
        id: "existing-id",
        account_number: "ACC-003",
        balance: 0,
        status: "active"
      }

      command = %OpenBankAccount{
        id: "new-id",
        account_number: "ACC-003",
        initial_balance: 500,
        status: "active"
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :account_already_opened}
    end
  end

  describe "BankAccount.execute/2 - DepositMoney" do
    @tag :unit
    test "returns MoneyDeposited event when account exists and is open" do
      aggregate = %BankAccount{
        id: "acc-id-001",
        account_number: "ACC-001",
        balance: 500,
        status: "active"
      }

      command = %DepositMoney{
        account_number: "ACC-001",
        amount: 300
      }

      result = BankAccount.execute(aggregate, command)

      assert result == %MoneyDeposited{
               account_number: "ACC-001",
               amount: 300
             }
    end

    @tag :unit
    test "returns error when account does not exist (account_number is nil)" do
      aggregate = %BankAccount{account_number: nil}

      command = %DepositMoney{
        account_number: "ACC-999",
        amount: 100
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :not_found}
    end

    @tag :unit
    test "returns error when account is closed" do
      aggregate = %BankAccount{
        id: "acc-id-002",
        account_number: "ACC-002",
        balance: 1000,
        status: "inactive"
      }

      command = %DepositMoney{
        account_number: "ACC-002",
        amount: 500
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :account_closed}
    end
  end

  describe "BankAccount.execute/2 - WithdrawMoney" do
    @tag :unit
    test "returns MoneyWithdrawn event when sufficient balance exists" do
      aggregate = %BankAccount{
        id: "acc-id-003",
        account_number: "ACC-003",
        balance: 1000,
        status: "active"
      }

      command = %WithdrawMoney{
        account_number: "ACC-003",
        amount: 300
      }

      result = BankAccount.execute(aggregate, command)

      assert result == %MoneyWithdrawn{
               account_number: "ACC-003",
               amount: 300
             }
    end

    @tag :unit
    test "allows withdrawal that brings balance to exactly zero" do
      aggregate = %BankAccount{
        id: "acc-id-004",
        account_number: "ACC-004",
        balance: 500,
        status: "active"
      }

      command = %WithdrawMoney{
        account_number: "ACC-004",
        amount: 500
      }

      result = BankAccount.execute(aggregate, command)

      assert result == %MoneyWithdrawn{
               account_number: "ACC-004",
               amount: 500
             }
    end

    @tag :unit
    test "returns error when insufficient balance" do
      aggregate = %BankAccount{
        id: "acc-id-005",
        account_number: "ACC-005",
        balance: 100,
        status: "active"
      }

      command = %WithdrawMoney{
        account_number: "ACC-005",
        amount: 150
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :insufficient_funds}
    end

    @tag :unit
    test "returns error when account does not exist" do
      aggregate = %BankAccount{account_number: nil}

      command = %WithdrawMoney{
        account_number: "ACC-999",
        amount: 100
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :not_found}
    end

    @tag :unit
    test "returns error when account is closed" do
      aggregate = %BankAccount{
        id: "acc-id-006",
        account_number: "ACC-006",
        balance: 1000,
        status: "inactive"
      }

      command = %WithdrawMoney{
        account_number: "ACC-006",
        amount: 100
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :account_closed}
    end
  end

  describe "BankAccount.execute/2 - CloseBankAccount" do
    @tag :unit
    test "returns BankAccountClosed event when account exists and is open" do
      aggregate = %BankAccount{
        id: "acc-id-007",
        account_number: "ACC-007",
        balance: 0,
        status: "active"
      }

      command = %CloseBankAccount{
        account_number: "ACC-007"
      }

      result = BankAccount.execute(aggregate, command)

      assert result == %BankAccountClosed{
               account_number: "ACC-007",
               status: "inactive"
             }
    end

    @tag :unit
    test "can close account with positive balance" do
      aggregate = %BankAccount{
        id: "acc-id-008",
        account_number: "ACC-008",
        balance: 1000,
        status: "active"
      }

      command = %CloseBankAccount{
        account_number: "ACC-008"
      }

      result = BankAccount.execute(aggregate, command)

      assert result == %BankAccountClosed{
               account_number: "ACC-008",
               status: "inactive"
             }
    end

    @tag :unit
    test "returns error when account does not exist" do
      aggregate = %BankAccount{account_number: nil}

      command = %CloseBankAccount{
        account_number: "ACC-999"
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :not_found}
    end

    @tag :unit
    test "returns error when account is already closed" do
      aggregate = %BankAccount{
        id: "acc-id-009",
        account_number: "ACC-009",
        balance: 0,
        status: "inactive"
      }

      command = %CloseBankAccount{
        account_number: "ACC-009"
      }

      result = BankAccount.execute(aggregate, command)

      assert result == {:error, :account_closed}
    end
  end

  describe "BankAccount.apply/2 - Event Sourcing" do
    @tag :unit
    test "applies BankAccountOpened event to rebuild aggregate state" do
      # ARRANGE
      aggregate = %BankAccount{}

      event = %BankAccountOpened{
        id: "event-id-001",
        account_number: "ACC-010",
        initial_balance: 2000,
        status: "active"
      }

      # ACT
      result = BankAccount.apply(aggregate, event)

      # ASSERT
      assert result == %BankAccount{
               id: "event-id-001",
               account_number: "ACC-010",
               balance: 2000,
               status: "active"
             }
    end

    @tag :unit
    test "applies MoneyDeposited event to increment balance" do
      aggregate = %BankAccount{
        id: "acc-id-011",
        account_number: "ACC-011",
        balance: 500,
        status: "active"
      }

      event = %MoneyDeposited{
        account_number: "ACC-011",
        amount: 300
      }

      result = BankAccount.apply(aggregate, event)

      assert result.balance == 800
    end

    @tag :unit
    test "applies MoneyWithdrawn event to decrement balance" do
      aggregate = %BankAccount{
        id: "acc-id-012",
        account_number: "ACC-012",
        balance: 1000,
        status: "active"
      }

      event = %MoneyWithdrawn{
        account_number: "ACC-012",
        amount: 400
      }

      result = BankAccount.apply(aggregate, event)

      assert result.balance == 600
    end

    @tag :unit
    test "applies BankAccountClosed event to update status" do
      aggregate = %BankAccount{
        id: "acc-id-013",
        account_number: "ACC-013",
        balance: 100,
        status: "active"
      }

      event = %BankAccountClosed{
        account_number: "ACC-013",
        status: "inactive"
      }

      result = BankAccount.apply(aggregate, event)

      assert result.status == "inactive"
      assert result.balance == 100
    end

    @tag :unit
    test "applies sequence of events correctly (event sourcing replay)" do
      # ARRANGE: Start with empty aggregate
      aggregate = %BankAccount{}

      # ACT: Apply sequence of events
      aggregate =
        aggregate
        |> BankAccount.apply(%BankAccountOpened{
          id: "seq-id-001",
          account_number: "ACC-SEQ",
          initial_balance: 1000,
          status: "active"
        })
        |> BankAccount.apply(%MoneyDeposited{
          account_number: "ACC-SEQ",
          amount: 500
        })
        |> BankAccount.apply(%MoneyWithdrawn{
          account_number: "ACC-SEQ",
          amount: 300
        })

      # ASSERT: Final state is correct
      assert aggregate == %BankAccount{
               id: "seq-id-001",
               account_number: "ACC-SEQ",
               balance: 1200,
               status: "active"
             }
    end
  end
end
