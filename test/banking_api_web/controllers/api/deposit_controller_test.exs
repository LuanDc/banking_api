defmodule BankingApiWeb.Api.DepositControllerTest do
  use BankingApiWeb.ConnCase

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  describe "POST /api/bank_account/deposit" do
    @create_attrs %{"amount" => 100, "account_number" => "0001-01"}

    @tag :web
    test "success: deposits money, when data is valid", %{conn: conn} do
      dispatch(%OpenBankAccount{}, account_number: @create_attrs["account_number"])

      conn = post(conn, ~p"/api/bank_account/deposit", @create_attrs)

      assert response(conn, 201)
    end

    @tag :web
    test "error: returns error, when data is invalid", %{conn: conn} do
      dispatch(%OpenBankAccount{}, account_number: @create_attrs["account_number"])

      invalid_attrs = %{@create_attrs | "amount" => nil}

      conn = post(conn, ~p"/api/bank_account/deposit", invalid_attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag :web
    test "error: returns error, when account with the given number is not found", %{conn: conn} do
      conn = post(conn, ~p"/api/bank_account/deposit", @create_attrs)
      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end

    @tag :web
    test "error: returns error, when account is already closed", %{conn: conn} do
      dispatch(%OpenBankAccount{}, account_number: @create_attrs["account_number"])

      dispatch(%BankingApi.BankAccounts.Commands.CloseBankAccount{},
        account_number: @create_attrs["account_number"]
      )

      conn = post(conn, ~p"/api/bank_account/deposit", @create_attrs)
      assert json_response(conn, 422) == %{"error" => "Account closed"}
    end
  end
end
