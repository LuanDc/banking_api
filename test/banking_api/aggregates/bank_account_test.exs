defmodule BankingApi.Aggregates.BankAccountTest do
  use BankingApi.DataCase

  import Commanded.Assertions.EventAssertions

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Events.BankAccountOpened

  describe "OpenBankAccount" do
    test "make sure any event of BankAccountOpened type is published" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event.account_number == command.account_number
        assert event.initial_balance == command.initial_balance
        assert event.status == "open"
      end)
    end

    test "make sure aggregate state are what we wanted" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        bank_account = BankAccount.apply(%BankAccount{}, event)
        assert bank_account.id == command.id
        assert bank_account.account_number == command.account_number
        assert bank_account.balance == command.initial_balance
      end)
    end

    test "returns error when account is already openened" do
      command = build_command(:open_bank_account, account_number: "ACC-duplicated")

      assert :ok = BankingApiApp.dispatch(command)
      assert BankingApiApp.dispatch(command) == {:error, :account_already_opened}
    end
  end
end
