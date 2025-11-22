defmodule BankingApiWeb.Api.DepositControllerTest do
  use BankingApiWeb.ConnCase

  @create_attrs %{"amount" => 100, "account_number" => "0001-01"}
  @invalid_attrs %{"amount" => nil}

  describe "POST /api/bank_account/:account_number/deposit" do
    test "renders deposit when data is valid", %{conn: conn} do
      %{account_number: account_number} = dispatch(:open_bank_account)

      conn =
        post(conn, ~p"/api/bank_account/#{account_number}/deposit", @create_attrs)

      assert %{
               "account_number" => "ACC-123456",
               "balance" => 100,
               "id" => _,
               "status" => "open"
             } = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      %{account_number: account_number} = dispatch(:open_bank_account)

      conn =
        post(conn, ~p"/api/bank_account/#{account_number}/deposit", @invalid_attrs)

      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag :web
    test "respond with 404 when account with the given number is not found", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/bank_account/ACC-123/deposit", @create_attrs)
        |> json_response(404)

      assert response == %{"error" => "Not found!"}
    end
  end
end
