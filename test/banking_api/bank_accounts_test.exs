defmodule BankingApi.BankAccountsTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Projections.BankAccount

  import BankingApi.CommandsFactory

  describe "open_bank_account/1" do
    @params %{
      "initial_balance" => 1000,
      "account_number" => "1234567890",
      "status" => "open"
    }

    test "returns the opened account when the account is opened successfully" do
      assert {:ok, %BankAccount{} = bank_account} = BankAccounts.open_bank_account(@params)
      assert Ecto.UUID.cast!(bank_account.id)
      assert bank_account.balance == @params["initial_balance"]
      assert bank_account.account_number == @params["account_number"]
      assert bank_account.status == String.to_atom(@params["status"])
    end

    test "returns an error with the reason when an error in aggregation layer happens" do
      dispatch(:open_bank_account, account_number: "duplicated_account_number")

      params = Map.merge(@params, %{"account_number" => "duplicated_account_number"})

      assert BankAccounts.open_bank_account(params) == {:error, :account_already_opened}
    end

    for param <- Map.keys(@params) do
      test "returns an error with the reason when #{param} is not given" do
        params = Map.delete(@params, unquote(param))

        assert {:error, :validation_failure, error} =
                 BankAccounts.open_bank_account(params)

        error = Map.get(error, String.to_atom(unquote(param)))

        assert Enum.any?(error, &(&1 == "can't be empty"))
      end
    end

    test "returns an error when the given is status is not open or closed" do
      params = Map.put(@params, "status", "invalid_status")

      assert {:error, :validation_failure, error} = BankAccounts.open_bank_account(params)

      assert error.status == [~s(must be one of ["open", "closed"])]
    end
  end
end
