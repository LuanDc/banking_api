defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/open" do
    @tag :web
    test "success: opens a bank account when data is valid", %{conn: conn} do
      params = %{
        "initial_balance" => 1000,
        "account_number" => "0001-01",
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", params)

      response = json_response(conn, 201)
      assert response["account_number"] == "0001-01"
      assert response["balance"] == 1000
      assert response["status"] == "active"
    end

    @tag :web
    test "error: returns error when account_number is empty", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => 1000,
        "account_number" => nil,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "account_number" => ["can't be empty"]
               }
             }
    end

    @tag :web
    test "error: returns error when account_number is not a string", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => 1000,
        "account_number" => 12345,
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "account_number" => ["is not a valid string"]
               }
             }
    end

    @tag :web
    test "error: returns error when initial_balance is empty", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => nil,
        "account_number" => "ACC-001",
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "initial_balance" => ["must be a number greater than or equal to 0"]
               }
             }
    end

    @tag :web
    test "error: returns error when initial_balance is not a number", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => "1000",
        "account_number" => "ACC-001",
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "initial_balance" => ["must be a number greater than or equal to 0"]
               }
             }
    end

    @tag :web
    test "error: returns error when initial_balance is negative", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => -100,
        "account_number" => "ACC-001",
        "status" => "active"
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "initial_balance" => ["must be a number greater than or equal to 0"]
               }
             }
    end

    @tag :web
    test "error: returns error when status is empty", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => 1000,
        "account_number" => "ACC-001",
        "status" => nil
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "status" => ["must be one of [\"active\", \"inactive\"]"]
               }
             }
    end

    @tag :web
    test "error: returns error when status is invalid", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => 1000,
        "account_number" => "ACC-001",
        "status" => "closed"
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "status" => ["must be one of [\"active\", \"inactive\"]"]
               }
             }
    end

    @tag :web
    test "error: returns error when status is not a string", %{conn: conn} do
      invalid_params = %{
        "initial_balance" => 1000,
        "account_number" => "ACC-001",
        "status" => 1
      }

      conn = post(conn, ~p"/api/bank_account/open", invalid_params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "status" => ["must be one of [\"active\", \"inactive\"]"]
               }
             }
    end
  end
end
