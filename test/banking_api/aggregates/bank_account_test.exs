defmodule BankingApi.Aggregates.BankAccountTest do
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  use BankingApi.DataCase

  import Commanded.Assertions.EventAssertions

  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.MoneyDeposited

  describe "OpenBankAccount" do
    @tag :unit
    test "success: make sure any event of BankAccountCreated type is published" do
      command = build_command(%OpenBankAccount{})
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event == %BankAccountOpened{
                 account_number: command.account_number,
                 id: command.id,
                 status: "open"
               }
      end)
    end

    @tag :unit
    test "success: make sure any event of MoneyDeposit type is published" do
      command = build_command(%OpenBankAccount{})
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event == %MoneyDeposited{
                 account_number: command.account_number,
                 amount: command.initial_balance
               }
      end)
    end

    @tag :integration
    test "error: returns error when account already opened" do
      dispatch(%OpenBankAccount{},
        account_number: "duplicated_account_number"
      )

      command = build_command(%OpenBankAccount{}, account_number: "duplicated_account_number")

      assert BankingApiApp.dispatch(command) == {:error, :account_already_opened}
    end
  end
end
