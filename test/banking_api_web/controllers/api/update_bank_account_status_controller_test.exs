defmodule BankingApiWeb.Api.UpdateBankAccountStatusControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/status" do
    @tag :web
    test "success: updates bank account status to inactive", %{conn: conn} do
      bank_account = setup_bank_account()

      params = %{
        "id" => bank_account.id,
        "status" => "inactive"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 200) == %{
               "id" => bank_account.id,
               "account_number" => bank_account.account_number,
               "balance" => 0,
               "status" => "inactive"
             }
    end

    @tag :web
    test "success: updates bank account status to active", %{conn: conn} do
      bank_account = setup_closed_bank_account()

      params = %{
        "id" => bank_account.id,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 200) == %{
               "id" => bank_account.id,
               "account_number" => bank_account.account_number,
               "balance" => 0,
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
      bank_account = setup_bank_account()

      params = %{
        "id" => bank_account.id,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/status", params)

      assert json_response(conn, 422) == %{"error" => "Status already set"}
    end

    @tag :web
    test "error: returns error when id is empty", %{conn: conn} do
      invalid_params = %{"id" => nil, "status" => "inactive"}

      conn = post(conn, ~p"/api/bank_account/status", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "id" => ["can't be empty", "must be valid"]
               }
             }
    end

    @tag :web
    test "error: returns error when id is a invalid UUID", %{conn: conn} do
      invalid_params = %{"id" => "invalid_uuid", "status" => "inactive"}

      conn = post(conn, ~p"/api/bank_account/status", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "id" => ["must be valid"]
               }
             }
    end

    @tag :web
    test "error: returns error when status is empty", %{conn: conn} do
      invalid_params = %{"id" => Ecto.UUID.generate(), "status" => nil}

      conn = post(conn, ~p"/api/bank_account/status", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "status" => ["must be one of [\"active\", \"inactive\"]"]
               }
             }
    end

    @tag :web
    test "error: returns error when status is invalid", %{conn: conn} do
      invalid_params = %{"id" => Ecto.UUID.generate(), "status" => "closed"}

      conn = post(conn, ~p"/api/bank_account/status", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "status" => ["must be one of [\"active\", \"inactive\"]"]
               }
             }
    end

    @tag :web
    test "error: returns error when status is not a string", %{conn: conn} do
      invalid_params = %{"id" => Ecto.UUID.generate(), "status" => 1}

      conn = post(conn, ~p"/api/bank_account/status", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "status" => ["must be one of [\"active\", \"inactive\"]"]
               }
             }
    end
  end
end
