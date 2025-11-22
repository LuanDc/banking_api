defmodule BankingApi.Aggregates.BankAccountTest do
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  use BankingApi.DataCase

  import Commanded.Assertions.EventAssertions

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.MoneyDeposited

  describe "OpenBankAccount" do
    @tag :unit
    test "make sure any event of BankAccountCreated type is published" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event.account_number == command.account_number
        assert event.id == command.id
      end)
    end

    @tag :unit
    test "make sure any event of MoneyDeposit type is published" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event.account_number == command.account_number
        assert event.balance == command.initial_balance
      end)
    end

    @tag :unit
    test "make sure aggregate state are what we wanted" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        bank_account = BankAccount.apply(%BankAccount{}, event)
        assert bank_account.status == command.status
      end)
    end
  end
end
