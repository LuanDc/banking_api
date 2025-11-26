defmodule BankingApiWeb.Api.OpenBankAccountControllerTest do
  use BankingApiWeb.ConnCase

  describe "POST /api/bank_account/open" do
    @open_account_params %{
      "initial_balance" => 1000,
      "account_number" => "0001-01",
      "status" => "open"
    }

    @invalid_params %{"account_number" => nil}

    @tag :web
    test "success: opens a bank account", %{conn: conn} do
      conn = post(conn, ~p"/api/bank_account/open", @open_account_params)
      assert response(conn, 201)
    end

    @tag :web
    test "error: returns error, when the given account already exists", %{
      conn: conn
    } do
      params = Map.merge(@open_account_params, %{"account_number" => "duplicated_account_number"})

      conn =
        1..2
        |> Enum.map(fn _ -> post(conn, ~p"/api/bank_account/open", params) end)
        |> Enum.fetch!(1)

      assert json_response(conn, 422) == %{"error" => "Account already opened"}
    end

    @tag :web
    test "error: returns error, when the given attributes are invalid", %{
      conn: conn
    } do
      conn = post(conn, ~p"/api/bank_account/open", @invalid_params)

      assert json_response(conn, 400)["error"] != %{}
    end
  end
end
