defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  import BankingApi.CommandsFactory

  describe "POST /api/bank_account/open" do
    @params %{
      "initial_balance" => 1000,
      "account_number" => "1234567890",
      "status" => "open"
    }

    @tag :web
    test "successfully opens a bank account and respond with 201 status code", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/bank_account/open", @params)
        |> json_response(201)

      assert %{
               "account_number" => "1234567890",
               "balance" => 1000,
               "id" => _,
               "status" => "open"
             } = response
    end

    @tag :web
    test "fails to open bank account when account number already exists and respond with 422 status code",
         %{conn: conn} do
      dispatch(:open_bank_account, account_number: "duplicated_account_number")

      params = Map.merge(@params, %{"account_number" => "duplicated_account_number"})

      assert conn
             |> post(~p"/api/bank_account/open", params)
             |> json_response(422) == %{"error" => "Account already opened"}
    end

    @tag :web
    test "fails to open bank account when a validation error happens and respond with 400 status code",
         %{conn: conn} do
      params = Map.merge(@params, %{"account_number" => nil})

      assert %{"error" => errors} =
               conn
               |> post(~p"/api/bank_account/open", params)
               |> json_response(400)

      assert errors == %{"account_number" => ["can't be empty"]}
    end
  end
end
