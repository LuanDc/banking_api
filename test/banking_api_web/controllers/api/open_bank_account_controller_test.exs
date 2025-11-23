defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  import BankingApi.CommandsFactory

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  describe "POST /api/bank_account/open" do
    @open_account_params %{
      "initial_balance" => 1000,
      "account_number" => "0001-01",
      "status" => "open"
    }

    @invalid_params %{"account_number" => nil}

    @tag :web
    test "success: opens a bank account, returns account record", %{conn: conn} do
      conn = post(conn, ~p"/api/bank_account/open", @open_account_params)

      assert %{
               "account_number" => "0001-01",
               "balance" => 1000,
               "id" => _,
               "status" => "open"
             } = json_response(conn, 201)
    end

    @tag :web
    test "error: returns error when the given account already exists", %{
      conn: conn
    } do
      dispatch(%OpenBankAccount{}, account_number: "duplicated_account_number")

      params = Map.merge(@open_account_params, %{"account_number" => "duplicated_account_number"})

      conn = post(conn, ~p"/api/bank_account/open", params)

      assert json_response(conn, 422) == %{"error" => "Account already opened"}
    end

    @tag :web
    test "error: does not open account, returns when the given attributes are invalid", %{
      conn: conn
    } do
      conn = post(conn, ~p"/api/bank_account/open", @invalid_params)

      assert json_response(conn, 400)["error"] != %{}
    end
  end
end
