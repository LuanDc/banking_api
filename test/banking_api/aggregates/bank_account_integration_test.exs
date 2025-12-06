defmodule BankingApi.Aggregates.BankAccountIntegrationTest do
  use BankingApi.DataCase

  import Commanded.Assertions.EventAssertions

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankingApiApp

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

  alias Commanded.Aggregates.Aggregate

  describe "Commanded Integration - OpenBankAccount" do
    @tag :integration
    test "dispatches command, publishes event, and persists to event store" do
      open_bank_account = build_command(%OpenBankAccount{})

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event == %BankAccountOpened{
                 account_number: open_bank_account.account_number,
                 id: open_bank_account.id,
                 status: "active",
                 initial_balance: 0
               }
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.id}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 0,
                 status: "active"
               }
    end

    @tag :integration
    test "rejects duplicate account opening" do
      open_bank_account = build_command(%OpenBankAccount{})

      result = for(_ <- 1..2, do: BankingApiApp.dispatch(open_bank_account))

      assert Enum.fetch!(result, 0) == :ok
      assert Enum.fetch!(result, 1) == {:error, :account_already_opened}
    end
  end

  describe "Commanded Integration - DepositMoney" do
    @tag :integration
    test "dispatches deposit command and updates aggregate state" do
      open_bank_account = build_command(%OpenBankAccount{})

      deposit_money =
        build_command(%DepositMoney{},
          id: open_bank_account.id,
          amount: 100
        )

      assert BankingApiApp.dispatch([open_bank_account, deposit_money]) == :ok

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event.account_number == open_bank_account.account_number
        assert event.amount == deposit_money.amount
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.id}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 100,
                 status: "active"
               }
    end

    @tag :integration
    test "rejects deposit on non-existent account" do
      deposit_money = build_command(%DepositMoney{id: Ecto.UUID.generate(), amount: 100})

      assert BankingApiApp.dispatch(deposit_money) == {:error, :not_found}
    end
  end

  describe "Commanded Integration - WithdrawMoney" do
    @tag :integration
    test "dispatches withdrawal command and updates aggregate state" do
      initial_balance = 200
      withdrawal_amount = 100
      expected_balance = initial_balance - withdrawal_amount

      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: initial_balance)

      withdraw_money =
        build_command(%WithdrawMoney{},
          id: open_bank_account.id,
          amount: withdrawal_amount
        )

      assert BankingApiApp.dispatch([open_bank_account, withdraw_money]) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn, fn event ->
        assert event.account_number == open_bank_account.account_number
        assert event.amount == withdrawal_amount
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.id}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: expected_balance,
                 status: "active"
               }
    end

    @tag :integration
    test "rejects withdrawal when insufficient funds" do
      open_bank_account = build_command(%OpenBankAccount{})

      withdraw_money =
        build_command(%WithdrawMoney{},
          id: open_bank_account.id,
          amount: 1000
        )

      assert BankingApiApp.dispatch([open_bank_account, withdraw_money]) ==
               {:error, :insufficient_funds}
    end

    @tag :integration
    test "rejects withdrawal on non-existent account" do
      withdraw_money = build_command(%WithdrawMoney{id: Ecto.UUID.generate(), amount: 100})

      assert BankingApiApp.dispatch(withdraw_money) == {:error, :not_found}
    end
  end

  describe "Commanded Integration - CloseBankAccount" do
    @tag :integration
    test "dispatches close command and updates aggregate state" do
      open_bank_account = build_command(%OpenBankAccount{})

      close_bank_account =
        build_command(%CloseBankAccount{},
          id: open_bank_account.id
        )

      assert BankingApiApp.dispatch([open_bank_account, close_bank_account]) == :ok

      wait_for_event(BankingApiApp, BankAccountClosed, fn event ->
        assert event.account_number == open_bank_account.account_number
        assert event.status == "inactive"
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.id}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 0,
                 status: "inactive"
               }
    end

    @tag :integration
    test "rejects closing non-existent account" do
      close_bank_account = build_command(%CloseBankAccount{id: Ecto.UUID.generate()})

      assert BankingApiApp.dispatch(close_bank_account) == {:error, :not_found}
    end
  end

  describe "Commanded Integration - Operations on closed account" do
    @tag :integration
    test "rejects deposit on closed account" do
      account_number = "ACC-CLOSED-001"

      open_bank_account = build_command(%OpenBankAccount{}, account_number: account_number)

      close_bank_account =
        build_command(%CloseBankAccount{}, id: open_bank_account.id)

      deposit_money =
        build_command(%DepositMoney{}, id: open_bank_account.id, amount: 100)

      assert BankingApiApp.dispatch([open_bank_account, close_bank_account, deposit_money]) ==
               {:error, :account_closed}
    end

    @tag :integration
    test "rejects withdrawal from closed account" do
      account_number = "ACC-CLOSED-002"
      initial_balance = 100

      open_bank_account =
        build_command(%OpenBankAccount{},
          account_number: account_number,
          initial_balance: initial_balance
        )

      close_bank_account =
        build_command(%CloseBankAccount{}, id: open_bank_account.id)

      withdraw_money =
        build_command(%WithdrawMoney{}, id: open_bank_account.id, amount: 50)

      assert BankingApiApp.dispatch([open_bank_account, close_bank_account, withdraw_money]) ==
               {:error, :account_closed}
    end

    @tag :integration
    test "rejects closing already closed account" do
      account_number = "ACC-CLOSED-003"

      open_bank_account = build_command(%OpenBankAccount{}, account_number: account_number)

      close_bank_account_1 =
        build_command(%CloseBankAccount{}, id: open_bank_account.id)

      close_bank_account_2 =
        build_command(%CloseBankAccount{}, id: open_bank_account.id)

      assert BankingApiApp.dispatch([
               open_bank_account,
               close_bank_account_1,
               close_bank_account_2
             ]) ==
               {:error, :account_closed}
    end
  end
end
