defmodule BankingApi.BankAccounts.Projectors.BankAccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.BankAccountStatusUpdated
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  alias BankingApi.BankAccounts.Events.MoneyWithdrawn
  alias BankingApi.BankAccounts.Projectors.BankAccount, as: BankAccountProjector

  describe "project_bank_account_opened/2" do
    test "creates bank account insert operation in multi" do
      event = %BankAccountOpened{
        id: "123e4567-e89b-12d3-a456-426614174000",
        account_number: "ACC-001",
        status: "active",
        initial_balance: 1000
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_opened(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:insert, changeset, []} = Ecto.Multi.to_list(result_multi)[:bank_account]
      assert %Ecto.Changeset{} = changeset

      assert changeset.data.id == event.id
      assert changeset.data.account_number == event.account_number
      assert changeset.data.status == String.to_atom(event.status)
      assert changeset.data.balance == event.initial_balance
    end

    test "creates bank account with zero initial balance" do
      event = %BankAccountOpened{
        id: "123e4567-e89b-12d3-a456-426614174001",
        account_number: "ACC-002",
        status: "active",
        initial_balance: 0
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_opened(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:insert, changeset, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert changeset.data.balance == 0
      assert changeset.data.status == :active
    end

    test "converts status string to atom" do
      event = %BankAccountOpened{
        id: "123e4567-e89b-12d3-a456-426614174002",
        account_number: "ACC-003",
        status: "inactive",
        initial_balance: 500
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_opened(multi, event)

      assert {:insert, changeset, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert changeset.data.status == :inactive
    end
  end

  describe "project_money_deposited/2" do
    test "creates update operation to increment balance" do
      event = %MoneyDeposited{
        account_number: "ACC-003",
        amount: 500
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_money_deposited(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert %Ecto.Query{} = query

      assert Keyword.get(updates, :inc) == [balance: 500]
    end

    test "handles different deposit amounts" do
      event = %MoneyDeposited{
        account_number: "ACC-004",
        amount: 1500
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_money_deposited(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, _query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert Keyword.get(updates, :inc) == [balance: 1500]
    end
  end

  describe "project_money_withdrawn/2" do
    test "creates update operation to decrement balance" do
      event = %MoneyWithdrawn{
        account_number: "ACC-005",
        amount: 300
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_money_withdrawn(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert %Ecto.Query{} = query

      assert Keyword.get(updates, :inc) == [balance: -300]
    end

    test "handles different withdrawal amounts" do
      event = %MoneyWithdrawn{
        account_number: "ACC-006",
        amount: 750
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_money_withdrawn(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, _query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert Keyword.get(updates, :inc) == [balance: -750]
    end
  end

  describe "project_bank_account_closed/2" do
    test "creates update operation to set status to inactive" do
      event = %BankAccountClosed{
        account_number: "ACC-007",
        status: :inactive
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_closed(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert %Ecto.Query{} = query

      assert Keyword.get(updates, :set) == [status: :inactive]
    end
  end

  describe "project_bank_account_status_updated/2" do
    test "creates update operation to change status to active" do
      event = %BankAccountStatusUpdated{
        account_number: "ACC-008",
        status: "active"
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_status_updated(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert %Ecto.Query{} = query

      assert Keyword.get(updates, :set) == [status: :active]
    end

    test "creates update operation to change status to inactive" do
      event = %BankAccountStatusUpdated{
        account_number: "ACC-009",
        status: "inactive"
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_status_updated(multi, event)

      assert %Ecto.Multi{} = result_multi
      assert {:update_all, _query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert Keyword.get(updates, :set) == [status: :inactive]
    end

    test "converts status string to atom" do
      event = %BankAccountStatusUpdated{
        account_number: "ACC-010",
        status: "active"
      }

      multi = Ecto.Multi.new()

      result_multi = BankAccountProjector.project_bank_account_status_updated(multi, event)

      assert {:update_all, _query, updates, []} = Ecto.Multi.to_list(result_multi)[:bank_account]

      assert Keyword.get(updates, :set) == [status: :active]
    end
  end
end
