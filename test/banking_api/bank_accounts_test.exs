defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Projections.BankAccount

  import BankingApi.CommandsFactory

  describe "open_bank_account/1" do
    @params %{
      "initial_balance" => 1000,
      "account_number" => "1234567890",
      "status" => "open"
    }

    test "returns the opened account when the account is opened successfully" do
      assert {:ok, %BankAccount{} = bank_account} = BankAccounts.open_bank_account(@params)
      assert Ecto.UUID.cast!(bank_account.id)
      assert bank_account.balance == @params["initial_balance"]
      assert bank_account.account_number == @params["account_number"]
      assert bank_account.status == String.to_atom(@params["status"])
    end

    test "returns an validation failure with the reason when then given params are invalid" do
      params = Map.delete(@params, "account_number")

      assert BankAccounts.open_bank_account(params) ==
               {:error, :validation_failure, %{account_number: ["can't be empty"]}}
    end

    test "returns an error with the reason when an error in aggregation layer happens" do
      dispatch(:open_bank_account, account_number: "duplicated_account_number")

      params = Map.merge(@params, %{"account_number" => "duplicated_account_number"})

      assert BankAccounts.open_bank_account(params) == {:error, :account_already_opened}
    end
  end
end
