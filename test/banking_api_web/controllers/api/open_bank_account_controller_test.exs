defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/open" do
    @tag :web
    test "success: opens a bank account", %{conn: conn} do
      params = %{
        "initial_balance" => 1000,
        "account_number" => "0001-01",
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", params)
      assert response(conn, 201)
    end

    @tag :web
    test "error: returns error, when the given attributes are invalid", %{
      conn: conn
    } do
      invalid_params = %{
        "initial_balance" => nil,
        "account_number" => nil,
        "status" => nil
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400)["error"] != %{}
    end
  end
end
