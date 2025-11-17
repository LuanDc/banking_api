defmodule BankingApi.BankAccounts.Commands.OpenBankAccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  @params %{
    "initial_balance" => 1000,
    "account_number" => "1234567890",
    "status" => "open"
  }

  describe "new/1" do
    test "returns a OpenBankAccount command struct when the given params are valid" do
      bank_account = OpenBankAccount.new(@params)
      assert %OpenBankAccount{} = bank_account
      assert bank_account.initial_balance == @params["initial_balance"]
      assert bank_account.account_number == @params["account_number"]
      assert bank_account.status == @params["status"]
    end
  end
end
