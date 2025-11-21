defmodule BankingApi.Aggregates.BankAccountTest do
  use BankingApi.DataCase

  import Commanded.Assertions.EventAssertions

  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Events.BankAccountOpened

  describe "OpenBankAccount" do
    test "ensure any event of BankAccountOpened type is published" do
      command = build_command(:open_bank_account)
      assert :ok = BankingApiApp.dispatch(command)

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event.account_number == command.account_number
        assert event.initial_balance == command.initial_balance
        assert event.status == "open"
      end)
    end
  end
end
