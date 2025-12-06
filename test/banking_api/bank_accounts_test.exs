defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankAccounts.Projections.Transaction
  alias BankingApi.Repo

  import BankingApi.EventStoreHelper

  describe "open_bank_account/1" do
    @tag :integration
    test "read model is accessible with correct values" do
      account_number = Ecto.UUID.generate()

      valid_params = %{
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert {:ok, %BankAccount{} = bank_account} = BankAccounts.open_bank_account(valid_params)

      assert bank_account.balance == 1000
      assert bank_account.account_number == account_number

      transaction = Repo.get_by!(Transaction, bank_account_id: bank_account.id)

      refute is_nil(transaction)

      assert transaction.amount == 1000
      assert transaction.type == "deposit"
    end
  end

  describe "deposit/1" do
    @tag :integration
    test "read model is updated with new balance" do
      bank_account = setup_bank_account(balance: 0)

      params = %{"id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.deposit(params)

      assert updated_account.balance == 50
    end
  end

  describe "withdraw/1" do
    @tag :integration
    test "read model is updated with new balance" do
      bank_account = setup_bank_account(balance: 100)

      params = %{"id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.withdraw(params)

      assert updated_account.balance == 50
    end
  end

  describe "list_transactions/2" do
    @tag :integration
    test "returns transactions for account" do
      bank_account = setup_bank_account(balance: 0)

      params = %{"id" => bank_account.id, "amount" => 100}
      assert {:ok, _} = BankAccounts.deposit(params)

      transactions = BankAccounts.list_transactions(bank_account.id)

      assert length(transactions) > 0
    end
  end
end
