defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.Repo

  import BankingApi.CommandsFactory

  describe "open_bank_account/1" do
    @valid_attrs %{
      "initial_balance" => 1000,
      "account_number" => "0001-01",
      "status" => "open"
    }

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      assert BankAccounts.open_bank_account(@valid_attrs) == :ok

      account =
        Repo.get_by!(BankAccount,
          account_number: @valid_attrs["account_number"]
        )

      refute is_nil(account)
      assert account.status == :open
      assert account.balance == 1000
    end

    @tag :integration
    test "error: returns error when the command is not valid" do
      params = Map.put(@valid_attrs, "initial_balance", -1)

      assert {:error, :validation_failure, reason} = BankAccounts.open_bank_account(params)

      assert reason != %{}
    end

    test "error: returns error when aggregate rejects the command" do
      params = Map.put(@valid_attrs, "account_number", "ACC-1")

      result = for(_ <- 1..2, do: BankAccounts.open_bank_account(params))

      assert Enum.fetch!(result, 1) == {:error, :account_already_opened}
    end
  end

  describe "close_bank_account/1" do
    @valid_attrs %{"account_number" => "0001-01"}
    @invalid_attrs %{"account_number" => nil}

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      dispatch(%OpenBankAccount{}, account_number: @valid_attrs["account_number"])

      assert BankAccounts.close_bank_account(@valid_attrs) == :ok

      account = Repo.get_by(BankAccount, account_number: @valid_attrs["account_number"])

      assert account.status == :closed
    end

    @tag :integration
    test "error: returns error when the command is not valid" do
      assert {:error, :validation_failure, reason} =
               BankAccounts.open_bank_account(@invalid_attrs)

      assert reason != %{}
    end

    @tag :integration
    test "error: returns error when aggregate rejects the command" do
      response = BankAccounts.close_bank_account(@valid_attrs)

      assert response == {:error, :not_found}
    end
  end

  describe "deposit/1" do
    @valid_attrs %{"account_number" => "0001-01", "amount" => 50}
    @invalid_attrs %{"account_number" => nil, "amount" => 0}

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      dispatch(%OpenBankAccount{}, account_number: @valid_attrs["account_number"])

      assert BankAccounts.deposit(@valid_attrs) == :ok

      account = Repo.get_by(BankAccount, account_number: @valid_attrs["account_number"])

      assert account.balance == 50
    end

    @tag :integration
    test "error: returns error when the command is not valid" do
      assert {:error, :validation_failure, reason} =
               BankAccounts.deposit(@invalid_attrs)

      assert reason == %{account_number: ["can't be empty"]}
    end

    @tag :integration
    test "error: returns error when aggregate rejects the command" do
      response = BankAccounts.deposit(@valid_attrs)

      assert response == {:error, :not_found}
    end
  end

  describe "withdraw/1" do
    @valid_attrs %{"account_number" => "0001-01", "amount" => 50}
    @invalid_attrs %{"account_number" => nil, "amount" => 50}

    @tag :integration
    test "success: returns :ok and read model reflects final state" do
      dispatch(%OpenBankAccount{}, account_number: @valid_attrs["account_number"])
      dispatch(%DepositMoney{}, account_number: @valid_attrs["account_number"])

      assert BankAccounts.withdraw(@valid_attrs) == :ok

      account = Repo.get_by(BankAccount, account_number: @valid_attrs["account_number"])

      assert account.balance == 0
    end

    @tag :integration
    test "error: returns error when the command is not valid" do
      assert {:error, :validation_failure, reason} =
               BankAccounts.withdraw(@invalid_attrs)

      assert reason == %{account_number: ["can't be empty"]}
    end

    @tag :integration
    test "error: returns error when aggregate rejects the command" do
      response = BankAccounts.withdraw(@valid_attrs)

      assert response == {:error, :not_found}
    end
  end
end
