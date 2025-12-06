defmodule BankingApiWeb.Api.BankAccountControllerTest do
  use BankingApiWeb.ConnCase

  describe "GET /api/bank_account/:id" do
    @tag :web
    test "success: returns bank account when it exists", %{conn: conn} do
      bank_account = insert(:bank_account)

      conn = get(conn, ~p"/api/bank_account/#{bank_account.id}")

      assert json_response(conn, 200) == %{
               "id" => bank_account.id,
               "account_number" => bank_account.account_number,
               "balance" => bank_account.balance,
               "status" => Atom.to_string(bank_account.status)
             }
    end

    @tag :web
    test "error: returns 404 when account_number does not exist", %{conn: conn} do
      id = Ecto.UUID.generate()

      conn = get(conn, ~p"/api/bank_account/#{id}")

      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end
  end
end
