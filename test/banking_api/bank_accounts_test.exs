defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankingApiApp
  alias BankingApi.Repo

  import BankingApi.CommandsFactory

  # Helper functions
  defp create_account(account_number, initial_balance \\ 0) do
    open_bank_account =
      build_command(%OpenBankAccount{},
        account_number: account_number,
        initial_balance: initial_balance
      )

    BankingApiApp.dispatch(open_bank_account)
  end

  defp get_account!(account_number) do
    Repo.get_by!(BankAccount, account_number: account_number)
  end

  defp unique_account_number do
    "ACC-#{:rand.uniform(999_999)}"
  end

  describe "open_bank_account/1" do
    @valid_params %{
      "initial_balance" => 1000,
      "account_number" => "0001-01",
      "status" => "open"
    }

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      assert :ok = BankAccounts.open_bank_account(@valid_params)

      account = get_account!(@valid_params["account_number"])

      assert account.status == :open
      assert account.balance == 1000
    end

    @tag :integration
    test "error: returns validation error when initial balance is negative" do
      invalid_params = %{@valid_params | "initial_balance" => -1}

      assert {:error, :validation_failure, errors} =
               BankAccounts.open_bank_account(invalid_params)

      assert errors != %{}
    end

    test "error: returns error when account already exists" do
      account_number = "ACC-001"
      params = %{@valid_params | "account_number" => account_number}

      assert :ok = BankAccounts.open_bank_account(params)
      assert {:error, :account_already_opened} = BankAccounts.open_bank_account(params)
    end
  end

  describe "close_bank_account/1" do
    @account_number "ACC-002"
    @valid_params %{"account_number" => @account_number}
    @invalid_params %{"account_number" => nil}

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      create_account(@account_number)

      assert :ok = BankAccounts.close_bank_account(@valid_params)

      account = get_account!(@account_number)
      assert account.status == :closed
    end

    @tag :integration
    test "error: returns validation error when account number is nil" do
      assert {:error, :validation_failure, errors} =
               BankAccounts.close_bank_account(@invalid_params)

      assert errors == %{account_number: ["can't be empty"]}
    end

    @tag :integration
    test "error: returns not found when account does not exist" do
      assert {:error, :not_found} = BankAccounts.close_bank_account(@valid_params)
    end
  end

  describe "deposit/1" do
    @account_number "ACC-003"
    @deposit_amount 50
    @valid_params %{"account_number" => @account_number, "amount" => @deposit_amount}
    @invalid_params %{"account_number" => nil, "amount" => 0}

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      create_account(@account_number)

      assert :ok = BankAccounts.deposit(@valid_params)

      account = get_account!(@account_number)
      assert account.balance == @deposit_amount
    end

    @tag :integration
    test "error: returns validation error when account number is nil" do
      assert {:error, :validation_failure, errors} = BankAccounts.deposit(@invalid_params)

      assert errors == %{account_number: ["can't be empty"]}
    end

    @tag :integration
    test "error: returns not found when account does not exist" do
      assert {:error, :not_found} = BankAccounts.deposit(@valid_params)
    end
  end

  describe "withdraw/1" do
    @account_number "ACC-004"
    @initial_balance 100
    @withdraw_amount 50
    @valid_params %{"account_number" => @account_number, "amount" => @withdraw_amount}
    @invalid_params %{"account_number" => nil, "amount" => @withdraw_amount}

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      create_account(@account_number, @initial_balance)

      assert :ok = BankAccounts.withdraw(@valid_params)

      account = get_account!(@account_number)
      assert account.balance == @initial_balance - @withdraw_amount
    end

    @tag :integration
    test "error: returns validation error when account number is nil" do
      assert {:error, :validation_failure, errors} = BankAccounts.withdraw(@invalid_params)

      assert errors == %{account_number: ["can't be empty"]}
    end

    @tag :integration
    test "error: returns not found when account does not exist" do
      assert {:error, :not_found} = BankAccounts.withdraw(@valid_params)
    end

    @tag :integration
    test "error: returns insufficient funds when balance is too low" do
      account_number = unique_account_number()
      create_account(account_number, 10)

      params = %{"account_number" => account_number, "amount" => 100}

      assert {:error, :insufficient_funds} = BankAccounts.withdraw(params)
    end
  end

  describe "operations on closed account" do
    @tag :integration
    test "error: cannot deposit money on closed account" do
      account_number = unique_account_number()
      create_account(account_number)
      BankAccounts.close_bank_account(%{"account_number" => account_number})

      assert {:error, :account_closed} =
               BankAccounts.deposit(%{"account_number" => account_number, "amount" => 50})
    end

    @tag :integration
    test "error: cannot withdraw money from closed account" do
      account_number = unique_account_number()
      create_account(account_number, 100)
      BankAccounts.close_bank_account(%{"account_number" => account_number})

      assert {:error, :account_closed} =
               BankAccounts.withdraw(%{"account_number" => account_number, "amount" => 50})
    end

    @tag :integration
    test "error: cannot close an already closed account" do
      account_number = unique_account_number()
      create_account(account_number)

      assert :ok = BankAccounts.close_bank_account(%{"account_number" => account_number})

      assert {:error, :account_closed} =
               BankAccounts.close_bank_account(%{"account_number" => account_number})
    end
  end
end
