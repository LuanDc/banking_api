defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankingApiApp
  alias BankingApi.Repo

  import BankingApi.CommandsFactory

  describe "open_bank_account/1 - unit" do
    @tag :unit
    test "error: returns validation error when initial balance is negative" do
      invalid_params = %{
        "initial_balance" => -1,
        "account_number" => "0001-01",
        "status" => "active"
      }

      assert {:error, :validation_failure, errors} =
               BankAccounts.open_bank_account(invalid_params)

      assert errors != %{}
    end

    @tag :unit
    test "error: returns validation error when account number is missing" do
      invalid_params = %{
        "initial_balance" => 1000,
        "status" => "active"
      }

      assert {:error, :validation_failure, errors} =
               BankAccounts.open_bank_account(invalid_params)

      assert errors[:account_number] != nil
    end
  end

  describe "deposit/1 - unit" do
    @tag :unit
    test "error: returns validation error when id is nil" do
      invalid_params = %{"id" => nil, "amount" => 0}

      assert {:error, :validation_failure, errors} = BankAccounts.deposit(invalid_params)

      assert errors == %{id: ["must be valid"]}
    end

    @tag :unit
    test "error: returns validation error when id is invalid" do
      invalid_params = %{"id" => "invalid-uuid", "amount" => 100}

      assert {:error, :validation_failure, errors} = BankAccounts.deposit(invalid_params)

      assert errors[:id] == ["must be valid"]
    end

    @tag :unit
    test "error: returns validation error when amount is negative" do
      invalid_params = %{"id" => Ecto.UUID.generate(), "amount" => -10}

      assert {:error, :validation_failure, errors} = BankAccounts.deposit(invalid_params)

      assert errors[:amount] != nil
    end

    @tag :unit
    test "error: returns validation error when amount is missing" do
      invalid_params = %{"id" => Ecto.UUID.generate()}

      assert {:error, :validation_failure, errors} = BankAccounts.deposit(invalid_params)

      assert errors[:amount] != nil
    end
  end

  describe "withdraw/1 - unit" do
    @tag :unit
    test "error: returns validation error when id is nil" do
      invalid_params = %{"id" => nil, "amount" => 50}

      assert {:error, :validation_failure, errors} = BankAccounts.withdraw(invalid_params)

      assert errors == %{id: ["can't be empty", "must be valid"]}
    end

    @tag :unit
    test "error: returns validation error when id is invalid" do
      invalid_params = %{"id" => "invalid-uuid", "amount" => 50}

      assert {:error, :validation_failure, errors} = BankAccounts.withdraw(invalid_params)

      assert errors[:id] == ["must be valid"]
    end

    @tag :unit
    test "error: returns validation error when amount is negative" do
      invalid_params = %{"id" => Ecto.UUID.generate(), "amount" => -10}

      assert {:error, :validation_failure, errors} = BankAccounts.withdraw(invalid_params)

      assert errors[:amount] != nil
    end

    @tag :unit
    test "error: returns validation error when amount is missing" do
      invalid_params = %{"id" => Ecto.UUID.generate()}

      assert {:error, :validation_failure, errors} = BankAccounts.withdraw(invalid_params)

      assert errors[:amount] != nil
    end
  end

  # Integration tests - minimal smoke tests for the full flow
  describe "integration tests" do
    # Helper functions for integration tests only
    defp create_account(account_number, initial_balance \\ 0) do
      open_bank_account =
        build_command(%OpenBankAccount{},
          account_number: account_number,
          initial_balance: initial_balance
        )

      BankingApiApp.dispatch(open_bank_account)

      # Wait for projections
      Process.sleep(50)

      # Return the account
      Repo.get_by!(BankAccount, account_number: account_number)
    end

    defp get_account!(id) do
      Repo.get!(BankAccount, id)
    end

    defp unique_account_number do
      "ACC-#{:rand.uniform(999_999)}"
    end

    @tag :integration
    test "open_bank_account/1: success flow creates account with correct state" do
      valid_params = %{
        "initial_balance" => 1000,
        "account_number" => "0001-01",
        "status" => "active"
      }

      assert {:ok, bank_account} = BankAccounts.open_bank_account(valid_params)

      account = get_account!(bank_account.id)

      assert account.status == :active
      assert account.balance == 1000
    end

    @tag :integration
    test "deposit/1: success flow increases balance" do
      bank_account = create_account("ACC-003")

      params = %{"id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.deposit(params)

      assert updated_account.balance == 50
    end

    @tag :integration
    test "deposit/1: returns not found when account does not exist" do
      params = %{"id" => Ecto.UUID.generate(), "amount" => 50}

      assert {:error, :not_found} = BankAccounts.deposit(params)
    end

    @tag :integration
    test "withdraw/1: success flow decreases balance" do
      bank_account = create_account("ACC-004", 100)

      params = %{"id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.withdraw(params)

      assert updated_account.balance == 50
    end

    @tag :integration
    test "withdraw/1: returns not found when account does not exist" do
      params = %{"id" => Ecto.UUID.generate(), "amount" => 50}

      assert {:error, :not_found} = BankAccounts.withdraw(params)
    end

    @tag :integration
    test "withdraw/1: returns insufficient funds when balance is too low" do
      bank_account = create_account(unique_account_number(), 10)

      params = %{"id" => bank_account.id, "amount" => 100}

      assert {:error, :insufficient_funds} = BankAccounts.withdraw(params)
    end
  end
end
