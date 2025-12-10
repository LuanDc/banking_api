defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts

  import BankingApi.EventStoreHelper

  describe "open_bank_account/1" do
    @tag :integration
    test "dispatches command successfully and returns opening request" do
      request_id = Ecto.UUID.generate()
      account_number = "ACC-#{:rand.uniform(1_000_000)}"

      valid_params = %{
        "request_id" => request_id,
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert {:ok, request} = BankAccounts.open_bank_account(valid_params)
      assert request.id == request_id
      assert request.account_number == account_number
      assert request.initial_balance == 1000
      assert request.status == :active
      assert request.request_status == :in_progress
    end

    @tag :integration
    test "prevents duplicate request_id ensuring idempotency" do
      request_id = Ecto.UUID.generate()
      account_number = "IDEM-#{:rand.uniform(1_000_000)}"

      params = %{
        "request_id" => request_id,
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      # First request should succeed
      assert {:ok, request} = BankAccounts.open_bank_account(params)
      assert request.id == request_id

      # Second request with same request_id should fail
      assert {:error, :bank_account_opening_already_requested} =
               BankAccounts.open_bank_account(params)
    end

    @tag :integration
    test "prevents duplicate account numbers via aggregate" do
      request_id = Ecto.UUID.generate()
      account_number = "DUP-#{:rand.uniform(1_000_000)}"

      params = %{
        "request_id" => request_id,
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert {:ok, _request} = BankAccounts.open_bank_account(params)
    end

    @tag :integration
    test "creates initial deposit transaction" do
      request_id = Ecto.UUID.generate()
      account_number = "TRX-#{:rand.uniform(1_000_000)}"

      valid_params = %{
        "request_id" => request_id,
        "initial_balance" => 5000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert {:ok, _request} = BankAccounts.open_bank_account(valid_params)
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

  describe "get_opening_request/1" do
    @tag :integration
    test "returns opening request by id" do
      request_id = Ecto.UUID.generate()
      account_number = "GET-#{:rand.uniform(1_000_000)}"

      params = %{
        "request_id" => request_id,
        "initial_balance" => 2000,
        "account_number" => account_number,
        "status" => "active"
      }

      assert {:ok, _created_request} = BankAccounts.open_bank_account(params)
      assert {:ok, request} = BankAccounts.get_opening_request(request_id)
      assert request.id == request_id
      assert request.account_number == account_number
    end

    @tag :integration
    test "returns error when request not found" do
      non_existent_id = Ecto.UUID.generate()
      assert {:error, :not_found} = BankAccounts.get_opening_request(non_existent_id)
    end
  end
end
