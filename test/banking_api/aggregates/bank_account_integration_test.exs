defmodule BankingApi.Aggregates.BankAccountIntegrationTest do
  use BankingApi.DataCase

  import Commanded.Assertions.EventAssertions

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankingApiApp

  alias BankingApi.BankAccounts.Commands.{
    OpenBankAccount,
    DepositMoney,
    WithdrawMoney
  }

  alias BankingApi.BankAccounts.Events.{
    BankAccountOpened,
    MoneyDeposited,
    MoneyWithdrawn
  }

  alias Commanded.Aggregates.Aggregate

  describe "OpenBankAccount" do
    @tag :integration
    test "dispatches command, publishes event, and persists to event store" do
      open_bank_account = build_command(%OpenBankAccount{})

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert %BankAccountOpened{
                 account_number: account_number,
                 id: id,
                 status: "active",
                 initial_balance: 0
               } = event

        assert account_number == open_bank_account.account_number
        assert id == open_bank_account.id
        assert event.date != nil
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
  end

  describe "DepositMoney" do
    @tag :integration
    test "dispatches deposit command and updates aggregate state" do
      open_bank_account = build_command(%OpenBankAccount{})

      deposit_money =
        build_command(%DepositMoney{},
          bank_account_id: open_bank_account.id,
          amount: 100
        )

      assert BankingApiApp.dispatch([open_bank_account, deposit_money]) == :ok

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event.bank_account_id == open_bank_account.id
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
  end

  describe "WithdrawMoney" do
    @tag :integration
    test "dispatches withdrawal command and updates aggregate state" do
      initial_balance = 200
      withdrawal_amount = 100
      expected_balance = initial_balance - withdrawal_amount

      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: initial_balance)

      withdraw_money =
        build_command(%WithdrawMoney{},
          bank_account_id: open_bank_account.id,
          amount: withdrawal_amount
        )

      assert BankingApiApp.dispatch([open_bank_account, withdraw_money]) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn, fn event ->
        assert event.bank_account_id == open_bank_account.id
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
  end
end
