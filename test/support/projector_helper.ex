defmodule BankingApi.ProjectorHelper do
  @moduledoc """
  Helper functions for testing projectors in a consistent way across the codebase.

  This module provides utilities to extract and verify Ecto.Multi operations
  created by projector functions, making tests more readable and maintainable.

  ## Usage

      import BankingApi.ProjectorHelper

      test "creates bank account insert operation" do
        multi = Ecto.Multi.new()
        result_multi = BankAccountProjector.project_bank_account_opened(multi, event)

        changeset = assert_multi_insert(result_multi, :bank_account)

        assert changeset.data.id == event.id
      end
  """

  import ExUnit.Assertions

  @doc """
  Asserts that a multi contains an insert operation for the given key and returns the changeset.

  ## Parameters

    * `multi` - The Ecto.Multi to check
    * `key` - The operation key to extract (e.g., :bank_account)

  ## Examples

      changeset = assert_multi_insert(result_multi, :bank_account)
      assert changeset.data.id == "123"
  """
  def assert_multi_insert(multi, key) do
    assert %Ecto.Multi{} = multi
    assert {:insert, changeset, []} = Ecto.Multi.to_list(multi)[key]
    assert %Ecto.Changeset{} = changeset
    changeset
  end

  @doc """
  Asserts that a multi contains an update_all operation for the given key and returns the query and updates.

  ## Parameters

    * `multi` - The Ecto.Multi to check
    * `key` - The operation key to extract (e.g., :bank_account)

  ## Returns

    A tuple `{query, updates}` where:
    * `query` - The Ecto.Query used for the update
    * `updates` - The keyword list of updates

  ## Examples

      {query, updates} = assert_multi_update_all(result_multi, :bank_account)
      assert Keyword.get(updates, :inc) == [balance: 500]
  """
  def assert_multi_update_all(multi, key) do
    assert %Ecto.Multi{} = multi
    assert {:update_all, query, updates, []} = Ecto.Multi.to_list(multi)[key]
    assert %Ecto.Query{} = query
    {query, updates}
  end

  @doc """
  Asserts that a multi contains a delete_all operation for the given key and returns the query.

  ## Parameters

    * `multi` - The Ecto.Multi to check
    * `key` - The operation key to extract (e.g., :bank_account)

  ## Examples

      query = assert_multi_delete_all(result_multi, :bank_account)
      assert %Ecto.Query{} = query
  """
  def assert_multi_delete_all(multi, key) do
    assert %Ecto.Multi{} = multi
    assert {:delete_all, query, []} = Ecto.Multi.to_list(multi)[key]
    assert %Ecto.Query{} = query
    query
  end
end
