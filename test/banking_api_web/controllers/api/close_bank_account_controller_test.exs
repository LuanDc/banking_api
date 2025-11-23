defmodule BankingApiWeb.Api.CloseBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  import BankingApi.CommandsFactory

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  @close_attrs %{"account_number" => "0001-01"}

  describe "POST /api/bank_account/:account_number/close" do
    @tag :web
    test "successfully close a bank account and respond with 201 status code", %{conn: conn} do
      dispatch(%OpenBankAccount{}, account_number: @close_attrs["account_number"])

      conn = post(conn, ~p"/api/bank_account/close", @close_attrs)

      response = json_response(conn, 201)

      assert response["account_number"] == @close_attrs["account_number"]
      assert response["status"] == "closed"
    end

    @tag :web
    test "respond with 404 when account with the given number is not found", %{conn: conn} do
      invalid_attrs = %{"account_number" => "ACC-NON-EXISTENT"}

      conn = post(conn, ~p"/api/bank_account/close", invalid_attrs)

      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end
  end
end
