defmodule BankingApiWeb.Api.UpdateBankAccountStatusControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/status" do
    @tag :web
    test "success: updates bank account status to inactive", %{conn: conn} do
      bank_account = setup_bank_account("ACC-UPDATE-001", 1000)

      params = %{
        "id" => bank_account.id,
        "status" => "inactive"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 200) == %{
               "id" => bank_account.id,
               "account_number" => bank_account.account_number,
               "balance" => 1000,
               "status" => "inactive"
             }
    end

    @tag :web
    test "success: updates bank account status to active", %{conn: conn} do
      bank_account = setup_closed_bank_account("ACC-UPDATE-002", 500)

      params = %{
        "id" => bank_account.id,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 200) == %{
               "id" => bank_account.id,
               "account_number" => bank_account.account_number,
               "balance" => 500,
               "status" => "active"
             }
    end

    @tag :web
    test "error: returns error when account does not exist", %{conn: conn} do
      params = %{
        "id" => Ecto.UUID.generate(),
        "status" => "inactive"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end

    @tag :web
    test "error: returns error when status is already set", %{conn: conn} do
      bank_account = setup_bank_account("ACC-UPDATE-003", 1000)

      params = %{
        "id" => bank_account.id,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 422) == %{"error" => "Status already set"}
    end

    @tag :web
    test "error: returns validation error for invalid status", %{conn: conn} do
      bank_account = setup_bank_account("ACC-UPDATE-004", 1000)

      params = %{
        "id" => bank_account.id,
        "status" => "invalid"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 400)["error"] != %{}
    end

    @tag :web
    test "error: returns validation error when id is missing", %{conn: conn} do
      params = %{"status" => "inactive"}

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 400)["error"] != %{}
    end
  end
end
