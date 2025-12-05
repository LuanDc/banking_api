defmodule BankingApiWeb.Api.UpdateBankAccountStatusControllerTest do
  use BankingApiWeb.ConnCase

  import BankingApi.EventStoreHelper

  describe "POST /api/bank_account/status" do
    @tag :web
    test "success: updates bank account status to inactive", %{conn: conn} do
      account_number = "ACC-UPDATE-1"
      setup_bank_account(account_number, 1000)

      params = %{
        "account_number" => account_number,
        "status" => "inactive"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)
      response = json_response(conn, 200)

      assert response["status"] == "inactive"
      assert response["account_number"] == account_number
    end

    @tag :web
    test "success: updates bank account status to active", %{conn: conn} do
      account_number = "ACC-UPDATE-2"
      setup_closed_bank_account(account_number, 500)

      params = %{
        "account_number" => account_number,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)
      response = json_response(conn, 200)

      assert response["status"] == "active"
      assert response["account_number"] == account_number
    end

    @tag :web
    test "error: returns error when account does not exist", %{conn: conn} do
      params = %{
        "account_number" => "NON-EXISTENT",
        "status" => "inactive"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)
      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end

    @tag :web
    test "error: returns error when status is already set", %{conn: conn} do
      account_number = "ACC-UPDATE-3"
      setup_bank_account(account_number, 1000)

      params = %{
        "account_number" => account_number,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)
      assert json_response(conn, 422) == %{"error" => "Status already set"}
    end

    @tag :web
    test "error: returns validation error for invalid status", %{conn: conn} do
      params = %{
        "account_number" => "ACC-001",
        "status" => "invalid"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)
      assert json_response(conn, 400)["error"] != %{}
    end

    @tag :web
    test "error: returns validation error when account_number is missing", %{conn: conn} do
      params = %{"status" => "inactive"}

      conn = post(conn, ~p"/api/bank_account/status", params)
      assert json_response(conn, 400)["error"] != %{}
    end
  end
end
