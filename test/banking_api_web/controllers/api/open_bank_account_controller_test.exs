defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  import BankingApi.CommandsFactory

  describe "POST /api/bank_account/open" do
    @params %{
      "initial_balance" => 1000,
      "account_number" => "1234567890",
      "status" => "open"
    }

    @empty_params %{}

    test "successfully opens a bank account", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/bank_account/open", @params)
        |> json_response(200)

      assert %{
               "account_number" => "1234567890",
               "balance" => 1000,
               "id" => _,
               "status" => "open"
             } = response
    end

    test "fails to open bank account when account number already exists", %{conn: conn} do
      dispatch(:open_bank_account, account_number: "duplicated_account_number")

      params = Map.merge(@params, %{"account_number" => "duplicated_account_number"})

      assert conn
             |> post(~p"/api/bank_account/open", params)
             |> json_response(422) == %{"error" => "Account already opened"}
    end

    test "fails to open bank account when a validation error happens", %{conn: conn} do
      assert %{"error" => errors} =
               conn
               |> post(~p"/api/bank_account/open", @empty_params)
               |> json_response(400)

      assert Enum.map(errors, fn {key, value} -> Enum.any?(value, &(&1 == "can't be empty")) end)
    end
  end
end
