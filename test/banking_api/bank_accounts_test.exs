defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.Repo

  import BankingApi.EventStoreHelper

  describe "open_bank_account/1" do
    @tag :integration
    test "success: read model is accessible with correct values" do
      account_number = Ecto.UUID.generate()

      valid_params = %{
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert {:ok, %BankAccount{} = bank_account} = BankAccounts.open_bank_account(valid_params)

      account = Repo.get!(BankAccount, bank_account.id)

      assert account.balance == 1000
      assert account.account_number == account_number
    end

    @tag :integration
    test "error: validation failure returns errors" do
      invalid_params = %{
        "initial_balance" => -1,
        "account_number" => "0001-01",
        "status" => "active"
      }

      assert {:error, :validation_failure, errors} =
               BankAccounts.open_bank_account(invalid_params)

      assert errors != %{}
    end
  end

  describe "deposit/1" do
    @tag :integration
    test "success: read model is updated with new balance" do
      bank_account = setup_bank_account(balance: 0)

      params = %{"id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.deposit(params)

      assert updated_account.balance == 50
    end

    @tag :integration
    test "error: validation failure returns errors" do
      invalid_params = %{"id" => nil, "amount" => 0}

      assert {:error, :validation_failure, errors} = BankAccounts.deposit(invalid_params)

      assert errors != %{}
    end

    @tag :integration
    test "error: not found when account does not exist" do
      params = %{"id" => Ecto.UUID.generate(), "amount" => 50}

      assert {:error, reason} = BankAccounts.deposit(params)

      assert reason != nil
    end
  end

  describe "withdraw/1" do
    @tag :integration
    test "success: read model is updated with new balance" do
      bank_account = setup_bank_account(balance: 100)

      params = %{"id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.withdraw(params)

      assert updated_account.balance == 50
    end

    @tag :integration
    test "error: validation failure returns errors" do
      invalid_params = %{"id" => nil, "amount" => 50}

      assert {:error, :validation_failure, errors} = BankAccounts.withdraw(invalid_params)

      assert errors != %{}
    end

    @tag :integration
    test "error: insufficient funds when balance is too low" do
      bank_account = setup_bank_account(balance: 10)

      params = %{"id" => bank_account.id, "amount" => 100}

      assert {:error, reason} = BankAccounts.withdraw(params)

      assert reason != nil
    end
  end
end
