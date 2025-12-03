defmodule BankingApi.Aggregates.BankAccountTest do
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

  describe "OpenBankAccount" do
    @tag :unit
    test "success: make sure any event of BankAccountOpened type is published" do
      open_bank_account = build_command(%OpenBankAccount{})

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event == %BankAccountOpened{
                 account_number: open_bank_account.account_number,
                 id: open_bank_account.id,
                 status: "open",
                 initial_balance: 0
               }
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.account_number}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 0,
                 status: "open"
               }
    end

    @tag :integration
    test "error: returns error when account already opened" do
      open_bank_account = build_command(%OpenBankAccount{})

      result = for(_ <- 1..2, do: BankingApiApp.dispatch(open_bank_account))

      assert Enum.fetch!(result, 1) == {:error, :account_already_opened}
    end
  end

  describe "DepositMoney" do
    @tag :unit
    test "success: deposits money and publishes MoneyDeposited event" do
      open_bank_account = build_command(%OpenBankAccount{})

      deposit_money =
        build_command(%DepositMoney{},
          account_number: open_bank_account.account_number,
          amount: 100
        )

      assert BankingApiApp.dispatch([open_bank_account, deposit_money]) == :ok

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event.account_number == deposit_money.account_number
        assert event.amount == deposit_money.amount
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.account_number}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 100,
                 status: "open"
               }
    end

    @tag :unit
    test "error: returns error when account does not exist" do
      deposit_money = build_command(%DepositMoney{account_number: "non-existent", amount: 100})

      assert BankingApiApp.dispatch(deposit_money) == {:error, :not_found}
    end
  end

  describe "WithdrawMoney" do
    @tag :unit
    test "success: withdraws money and publishes MoneyWithdrawn event" do
      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: 200)

      withdraw_money =
        build_command(%WithdrawMoney{},
          account_number: open_bank_account.account_number,
          amount: 100
        )

      assert BankingApiApp.dispatch([open_bank_account, withdraw_money]) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn, fn event ->
        assert event.account_number == withdraw_money.account_number
        assert event.amount == 100
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.account_number}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 100,
                 status: "open"
               }
    end

    @tag :unit
    test "error: returns error when insufficient funds" do
      open_bank_account = build_command(%OpenBankAccount{})

      withdraw_money =
        build_command(%WithdrawMoney{},
          account_number: open_bank_account.account_number,
          amount: 1000
        )

      assert BankingApiApp.dispatch([open_bank_account, withdraw_money]) ==
               {:error, :insufficient_funds}
    end

    @tag :unit
    test "error: returns error when account does not exist" do
      withdraw_money = build_command(%WithdrawMoney{account_number: "non-existent", amount: 100})

      assert BankingApiApp.dispatch(withdraw_money) == {:error, :not_found}
    end
  end

  describe "CloseBankAccount" do
    @tag :unit
    test "success: closes account and publishes BankAccountClosed event" do
      open_bank_account = build_command(%OpenBankAccount{})

      close_bank_account =
        build_command(%CloseBankAccount{},
          account_number: open_bank_account.account_number
        )

      assert BankingApiApp.dispatch([open_bank_account, close_bank_account]) == :ok

      wait_for_event(BankingApiApp, BankAccountClosed, fn event ->
        assert event.account_number == close_bank_account.account_number
        assert event.status == "closed"
      end)

      assert Aggregate.aggregate_state(
               BankingApiApp,
               BankAccount,
               "bank-account-#{open_bank_account.account_number}"
             ) ==
               %BankAccount{
                 id: open_bank_account.id,
                 account_number: open_bank_account.account_number,
                 balance: 0,
                 status: "closed"
               }
    end

    @tag :unit
    test "error: returns error when account does not exist" do
      close_bank_account = build_command(%CloseBankAccount{account_number: "non-existent"})

      assert BankingApiApp.dispatch(close_bank_account) == {:error, :not_found}
    end
  end

  describe "Operations on closed account" do
    @tag :integration
    test "error: cannot deposit money on closed account" do
      open_bank_account = build_command(%OpenBankAccount{}, status: "open")

      close_bank_account =
        build_command(%CloseBankAccount{},
          account_number: open_bank_account.account_number
        )

      deposit_money =
        build_command(%DepositMoney{},
          account_number: open_bank_account.account_number,
          amount: 100
        )

      assert BankingApiApp.dispatch([open_bank_account, close_bank_account, deposit_money]) ==
               {:error, :account_closed}
    end

    @tag :integration
    test "error: cannot withdraw money from closed account" do
      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: 100)

      close_bank_account =
        build_command(%CloseBankAccount{},
          account_number: open_bank_account.account_number
        )

      withdraw_money =
        build_command(%WithdrawMoney{},
          account_number: open_bank_account.account_number,
          amount: 50
        )

      assert BankingApiApp.dispatch([open_bank_account, close_bank_account, withdraw_money]) ==
               {:error, :account_closed}
    end

    @tag :integration
    test "error: cannot close an already closed account" do
      open_bank_account = build_command(%OpenBankAccount{})

      close_bank_account_1 =
        build_command(%CloseBankAccount{},
          account_number: open_bank_account.account_number
        )

      close_bank_account_2 =
        build_command(%CloseBankAccount{},
          account_number: open_bank_account.account_number
        )

      assert BankingApiApp.dispatch([
               open_bank_account,
               close_bank_account_1,
               close_bank_account_2
             ]) ==
               {:error, :account_closed}
    end
  end
end
