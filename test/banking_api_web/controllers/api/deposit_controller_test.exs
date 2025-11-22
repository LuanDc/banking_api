defmodule BankingApiWeb.Api.DepositControllerTest do
  use BankingApiWeb.ConnCase

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  @create_attrs %{"amount" => 100, "account_number" => "0001-01"}
  @invalid_attrs %{"amount" => nil}

  describe "POST /api/bank_account/:account_number/deposit" do
    test "successfully deposit when data is valid", %{conn: conn} do
      %{account_number: account_number} =
        dispatch(%OpenBankAccount{})

      conn =
        post(conn, ~p"/api/bank_account/#{account_number}/deposit", @create_attrs)

      assert %{
               "account_number" => "ACC-123456",
               "balance" => 100,
               "id" => _,
               "status" => "open"
             } = json_response(conn, 201)
    end

    test "respond with errors when data is invalid", %{conn: conn} do
      %{account_number: account_number} =
        dispatch(%OpenBankAccount{})

      conn =
        post(conn, ~p"/api/bank_account/#{account_number}/deposit", @invalid_attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag :web
    test "respond with 404 when account with the given number is not found", %{conn: conn} do
      conn = post(conn, ~p"/api/bank_account/ACC-123/deposit", @create_attrs)
      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end

    @tag :web
    test "respond with 422 when account is already closed", %{conn: conn} do
      %{account_number: account_number} =
        dispatch(%OpenBankAccount{})

      dispatch(%BankingApi.BankAccounts.Commands.CloseBankAccount{})
      conn = post(conn, ~p"/api/bank_account/#{account_number}/deposit", @create_attrs)
      assert json_response(conn, 422) == %{"error" => "Account closed"}
    end
  end
end
