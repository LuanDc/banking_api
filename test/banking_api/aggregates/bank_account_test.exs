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
        assert event == %BankAccountOpened{
                 account_number: command.account_number,
                 id: command.id,
                 balance: 0,
                 status: "open"
               }
      end)
    end

    @tag :unit
    test "make sure any event of MoneyDeposit type is published" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event == %MoneyDeposited{
                 account_number: command.account_number,
                 balance: command.initial_balance
               }
      end)
    end
  end
end
