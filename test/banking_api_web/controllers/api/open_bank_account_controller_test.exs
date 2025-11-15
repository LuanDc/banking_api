defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/open" do
    @params %{
      "initial_balance" => 1000,
      "account_number" => "1234567890"
    }

    @empty_params %{}

    test "successfully opens a bank account", %{conn: conn} do
      assert conn
             |> post(~p"/api/bank_account/open", @params)
             |> response(200)
    end

    test "fails to open a bank account with negative initial balance", %{conn: conn} do
      params = Map.merge(@params, %{"initial_balance" => -1})

      assert conn
             |> post(~p"/api/bank_account/open", params)
             |> json_response(400) == %{
               "error" => %{"initial_balance" => ["must be a number greater than or equal to 0"]}
             }
    end

    test "fails to open bank account when params are empty", %{conn: conn} do
      assert conn
             |> post(~p"/api/bank_account/open", @empty_params)
             |> json_response(400) == %{
               "error" => %{
                 "initial_balance" => [
                   "can't be empty",
                   "must be a number greater than or equal to 0"
                 ],
                 "account_number" => ["can't be empty"]
               }
             }
    end

    test "fails to open bank account when account number already exists", %{conn: conn} do
      assert conn
             |> post(~p"/api/bank_account/open", @params)
             |> response(200)

      assert conn
             |> post(~p"/api/bank_account/open", @params)
             |> json_response(422) == %{"error" => "Account already opened"}
    end
  end
end
