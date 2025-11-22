defmodule BankingApiWeb.Api.CloseBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  import BankingApi.CommandsFactory

  describe "POST /api/bank_account/close" do
    @tag :web
    test "successfully close a bank account and respond with 201 status code", %{conn: conn} do
      %{account_number: account_number} = dispatch(:open_bank_account)

      response =
        conn
        |> post(~p"/api/bank_account/#{account_number}/close", %{})
        |> json_response(201)

      assert %{"account_number" => ^account_number, "status" => "closed"} = response
    end

    @tag :web
    test "respond with 404 when account with the given number is not found", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/bank_account/ACC-123/close", %{})
        |> json_response(404)

      assert response == %{"error" => "Not found!"}
    end
  end
end
