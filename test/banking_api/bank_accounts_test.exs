defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  import BankingApi.CommandsFactory

  describe "open_bank_account/1" do
    @valid_attrs %{
      "initial_balance" => 1000,
      "account_number" => "0001-01",
      "status" => "open"
    }

    @invalid_attrs %{"account_number" => nil}

    @tag :integration
    test "success: returns opened account record when account is opened successfully" do
      assert BankAccounts.open_bank_account(@valid_attrs) == :ok
    end

    @tag :integration
    test "success: returns ok when the given is status is open or closed" do
      for status <- ["open", "closed"] do
        params = %{@valid_attrs | "status" => status, "account_number" => "ACC-#{status}"}
        assert BankAccounts.open_bank_account(params) == :ok
      end
    end

    @tag :integration
    test "error: returns error with reason when required params aren't given" do
      assert {:error, :validation_failure, reason} =
               BankAccounts.open_bank_account(@invalid_attrs)

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
    test "error: returns error when the given account number is not a string" do
      params = %{@valid_attrs | "account_number" => 123_456}
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)
      assert reason == %{account_number: ["is not a valid string"]}
    end

    @tag :integration
    test "error: returns error when the given initial balance is less than 0" do
      params = %{@valid_attrs | "initial_balance" => -1}
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)
      assert reason == %{initial_balance: ["must be a number greater than or equal to 0"]}
    end

    @tag :integration
    test "error: returns error when the given is status is not open or closed" do
      params = %{@valid_attrs | "status" => "invalid_status"}
      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)
      assert reason == %{status: ["must be one of [\"open\", \"closed\"]"]}
    end

    @tag :integration
    test "error: returns error when account already opened" do
      dispatch(%OpenBankAccount{},
        account_number: "duplicated_account_number"
      )

      params = %{@valid_attrs | "account_number" => "duplicated_account_number"}
      assert BankAccounts.open_bank_account(params) == {:error, :account_already_opened}
    end
  end

  describe "close_bank_account/1" do
    @valid_attrs %{"account_number" => "0001-01"}
    @invalid_attrs %{"account_number" => nil}

    @tag :integration
    test "success: closes a bank account, returns account record" do
      dispatch(%OpenBankAccount{}, account_number: @valid_attrs["account_number"])

      assert BankAccounts.close_bank_account(@valid_attrs) == :ok
    end

    @tag :integration
    test "success: returns account record, when account is already closed" do
      dispatch(%OpenBankAccount{}, account_number: @valid_attrs["account_number"])

      assert BankAccounts.close_bank_account(@valid_attrs) == :ok
    end

    @tag :integration
    test "error: returns error with reason, when account is not found" do
      response = BankAccounts.close_bank_account(@valid_attrs)

      assert response == {:error, :not_found}
    end

    @tag :integration
    test "error: returns error with reason, when required params aren't given" do
      assert {:error, :validation_failure, reason} =
               BankAccounts.close_bank_account(@invalid_attrs)

      assert reason == %{account_number: ["can't be empty"]}
    end

    @tag :integration
    test "error: returns error, when the given account number is not a string" do
      invalid_attrs = %{@valid_attrs | "account_number" => 123_456}

      assert {:error, :validation_failure, reason} =
               BankAccounts.close_bank_account(invalid_attrs)

      assert reason == %{account_number: ["is not a valid string"]}
    end
  end
end
