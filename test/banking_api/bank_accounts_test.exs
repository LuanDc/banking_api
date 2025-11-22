defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Projections.BankAccount

  import BankingApi.CommandsFactory

  describe "open_bank_account/1" do
    @params %{
      "initial_balance" => 1000,
      "account_number" => "1234567890",
      "status" => "open"
    }

    @tag :integration
    test "returns the opened account when the account is opened successfully" do
      assert {:ok, %BankAccount{} = bank_account} = BankAccounts.open_bank_account(@params)
      assert validate_uuid_format(bank_account.id)
      assert bank_account.balance == @params["initial_balance"]
      assert bank_account.account_number == @params["account_number"]
      assert bank_account.status == String.to_atom(@params["status"])
    end

    @tag :integration
    test "returns true when the given is status is open or closed" do
      for status <- ["open", "closed"] do
        params = %{@params | "status" => status, "account_number" => "ACC-#{status}"}
        assert {:ok, %BankAccount{}} = BankAccounts.open_bank_account(params)
      end
    end

    @tag :integration
    test "returns error with reason when required params aren't given" do
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(%{})

      assert reason == %{
               status: ["can't be empty", "must be one of [\"open\", \"closed\"]"],
               account_number: ["can't be empty"],
               initial_balance: [
                 "can't be empty",
                 "must be a number greater than or equal to 0"
               ]
             }
    end

    @tag :integration
    test "returns false when the given account number is not a string" do
      params = %{@params | "account_number" => 123_456}
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)
      assert reason == %{account_number: ["is not a valid string"]}
    end

    @tag :integration
    test "returns false when the given initial balance is less than 0" do
      params = %{@params | "initial_balance" => -1}
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)
      assert reason == %{initial_balance: ["must be a number greater than or equal to 0"]}
    end

    @tag :integration
    test "returns false when the given is status is not open or closed" do
      params = %{@params | "status" => "invalid_status"}
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)
      assert reason == %{status: ["must be one of [\"open\", \"closed\"]"]}
    end

    @tag :integration
    test "returns an error when account already opened" do
      dispatch(%OpenBankAccount{},
        account_number: "duplicated_account_number"
      )

      params = %{@params | "account_number" => "duplicated_account_number"}
      assert BankAccounts.open_bank_account(params) == {:error, :account_already_opened}
    end
  end
end
