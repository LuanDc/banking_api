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

    @tag :web
    test "error: returns error when trying to open account with duplicate account_number", %{
      conn: conn
    } do
      account_number = "DUPLICATE-#{:rand.uniform(1_000_000)}"

      params = %{
        "initial_balance" => 1000,
        "account_number" => account_number,
        "status" => "active"
      }

      conn1 = post(conn, ~p"/api/bank_account/open", params)
      assert json_response(conn1, 201)

      conn2 = post(conn, ~p"/api/bank_account/open", params)
      assert json_response(conn2, 422) == %{"error" => "Account number already taken"}
    end

    @tag :web
    test "success: allows opening multiple accounts with different account_numbers", %{
      conn: conn
    } do
      account_number_1 = "ACC-#{:rand.uniform(1_000_000)}"
      account_number_2 = "ACC-#{:rand.uniform(1_000_000)}"

      params1 = %{
        "initial_balance" => 1000,
        "account_number" => account_number_1,
        "status" => "active"
      }

      params2 = %{
        "initial_balance" => 2000,
        "account_number" => account_number_2,
        "status" => "active"
      }

      conn1 = post(conn, ~p"/api/bank_account/open", params1)
      response1 = json_response(conn1, 201)
      assert response1["account_number"] == account_number_1

      conn2 = post(conn, ~p"/api/bank_account/open", params2)
      response2 = json_response(conn2, 201)
      assert response2["account_number"] == account_number_2
    end
  end
end
