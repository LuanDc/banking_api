defmodule BankingApiWeb.Api.WithdrawControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/withdraw" do
    @tag :web
    test "success: withdraws money when data is valid", %{conn: conn} do
      bank_account = setup_bank_account("ACC-WITHDRAW-001", 200)

      params = %{
        "id" => bank_account.id,
        "amount" => 100
      }

      conn = post(conn, ~p"/api/bank_account/withdraw", params)

      assert json_response(conn, 201) == %{
               "id" => bank_account.id,
               "account_number" => bank_account.account_number,
               "balance" => 100,
               "status" => "active"
             }
    end

    @tag :web
    test "error: returns error when account doesn't have sufficient funds", %{conn: conn} do
      bank_account = setup_bank_account("ACC-WITHDRAW-002", 50)

      params = %{
        "id" => bank_account.id,
        "amount" => 100
      }

      conn = post(conn, ~p"/api/bank_account/withdraw", params)

      assert json_response(conn, 422) == %{"error" => "Insufficient funds"}
    end

    @tag :web
    test "error: returns error when data is invalid", %{conn: conn} do
      invalid_params = %{
        "id" => nil,
        "amount" => nil
      }

      conn = post(conn, ~p"/api/bank_account/withdraw", invalid_params)

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag :web
    test "error: returns error when account with the id is not found", %{conn: conn} do
      params = %{
        "id" => Ecto.UUID.generate(),
        "amount" => 100
      }

      conn = post(conn, ~p"/api/bank_account/withdraw", params)

      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end

    @tag :web
    test "error: returns error when account is already closed", %{conn: conn} do
      bank_account = setup_closed_bank_account("ACC-WITHDRAW-003", 100)

      params = %{
        "id" => bank_account.id,
        "amount" => 50
      }

      conn = post(conn, ~p"/api/bank_account/withdraw", params)

      assert json_response(conn, 422) == %{"error" => "Account closed"}
    end
  end
end
