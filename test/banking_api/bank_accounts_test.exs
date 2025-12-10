defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts

  import BankingApi.EventStoreHelper

  defp wait_for_account(_account_number, 0), do: raise("Account not created in time")

  defp wait_for_account(account_number, retries) do
    case BankingApi.Repo.get_by(BankingApi.BankAccounts.Projections.BankAccount,
           account_number: account_number
         ) do
      nil ->
        :timer.sleep(200)
        wait_for_account(account_number, retries - 1)

      account ->
        account
    end
  end

  describe "open_bank_account/1" do
    @tag :integration
    test "dispatches command successfully and account is created asynchronously" do
      account_number = "ACC-#{:rand.uniform(1_000_000)}"

      valid_params = %{
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert :ok = BankAccounts.open_bank_account(valid_params)

      # Wait for async process manager to complete with retry
      bank_account = wait_for_account(account_number, 10)

      assert bank_account.account_number == account_number
      assert bank_account.balance == 1000
      assert bank_account.status == "active"
    end

    @tag :integration
    test "prevents duplicate account numbers via aggregate" do
      account_number = "DUP-#{:rand.uniform(1_000_000)}"

      params = %{
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      # First account should succeed
      assert :ok = BankAccounts.open_bank_account(params)
      _bank_account = wait_for_account(account_number, 10)

      # Second account with same number should fail at the aggregate level
      assert :ok = BankAccounts.open_bank_account(params)
      :timer.sleep(500)

      # Only one account should exist
      accounts =
        BankingApi.Repo.all(
          from a in BankingApi.BankAccounts.Projections.BankAccount,
            where: a.account_number == ^account_number
        )

      assert length(accounts) == 1
    end

    @tag :integration
    test "creates initial deposit transaction" do
      account_number = "TRX-#{:rand.uniform(1_000_000)}"

      valid_params = %{
        "initial_balance" => 5000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert :ok = BankAccounts.open_bank_account(valid_params)

      bank_account = wait_for_account(account_number, 10)
      transactions = BankAccounts.list_transactions(bank_account.id)

      assert length(transactions) == 1
      assert hd(transactions).amount == 5000
      assert hd(transactions).type == "deposit"
    end
  end

  describe "deposit/1" do
    @tag :integration
    test "read model is updated with new balance" do
      bank_account = setup_bank_account(balance: 0)

      params = %{"bank_account_id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.deposit(params)

      assert updated_account.balance == 50
    end
  end

  describe "withdraw/1" do
    @tag :integration
    test "read model is updated with new balance" do
      bank_account = setup_bank_account(balance: 100)

      params = %{"bank_account_id" => bank_account.id, "amount" => 50}

      assert {:ok, updated_account} = BankAccounts.withdraw(params)

      assert updated_account.balance == 50
    end
  end

  describe "list_transactions/2" do
    @tag :integration
    test "returns transactions for account" do
      bank_account = setup_bank_account(balance: 0)

      params = %{"bank_account_id" => bank_account.id, "amount" => 100}
      assert {:ok, _} = BankAccounts.deposit(params)

      transactions = BankAccounts.list_transactions(bank_account.id)

      assert length(transactions) > 0
    end
  end
end
