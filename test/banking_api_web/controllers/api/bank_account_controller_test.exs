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
    test "error: returns 404 when bank account does not exist", %{conn: conn} do
      id = Ecto.UUID.generate()

      conn = get(conn, ~p"/api/bank_account/#{id}")

      assert json_response(conn, 404) == %{"error" => "Not found!"}
    end
  end

  describe "GET /api/bank_account/:id/transactions" do
    @tag :web
    test "success: returns all transactions for an account", %{conn: conn} do
      bank_account = insert(:bank_account)

      transaction1 =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          amount: 100,
          type: "deposit"
        )

      transaction2 =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          amount: 50,
          type: "withdrawal"
        )

      conn = get(conn, ~p"/api/bank_account/#{bank_account.id}/transactions")

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 2
      assert Enum.any?(response["transactions"], fn t -> t["id"] == transaction1.id end)
      assert Enum.any?(response["transactions"], fn t -> t["id"] == transaction2.id end)
    end

    @tag :web
    test "success: returns transactions filtered by start_date", %{conn: conn} do
      bank_account = insert(:bank_account)
      old_date = DateTime.utc_now() |> DateTime.add(-2, :day)
      recent_date = DateTime.utc_now()

      _old_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: old_date
        )

      recent_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: recent_date
        )

      start_date = DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.to_iso8601()

      conn =
        get(
          conn,
          ~p"/api/bank_account/#{bank_account.id}/transactions?start_date=#{start_date}"
        )

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 1
      assert hd(response["transactions"])["id"] == recent_transaction.id
    end

    @tag :web
    test "success: returns transactions filtered by end_date", %{conn: conn} do
      bank_account = insert(:bank_account)
      old_date = DateTime.utc_now() |> DateTime.add(-2, :day)
      recent_date = DateTime.utc_now()

      old_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: old_date
        )

      _recent_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: recent_date
        )

      end_date = DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.to_iso8601()

      conn =
        get(
          conn,
          ~p"/api/bank_account/#{bank_account.id}/transactions?end_date=#{end_date}"
        )

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 1
      assert hd(response["transactions"])["id"] == old_transaction.id
    end

    @tag :web
    test "success: returns transactions filtered by date range", %{conn: conn} do
      bank_account = insert(:bank_account)
      old_date = DateTime.utc_now() |> DateTime.add(-3, :day)
      middle_date = DateTime.utc_now() |> DateTime.add(-2, :day)
      recent_date = DateTime.utc_now()

      _old_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: old_date
        )

      middle_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: middle_date
        )

      _recent_transaction =
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          date: recent_date
        )

      start_date =
        DateTime.utc_now()
        |> DateTime.add(-2, :day)
        |> DateTime.add(-1, :hour)
        |> DateTime.to_iso8601()

      end_date = DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.to_iso8601()

      conn =
        get(
          conn,
          ~p"/api/bank_account/#{bank_account.id}/transactions?start_date=#{start_date}&end_date=#{end_date}"
        )

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 1
      assert hd(response["transactions"])["id"] == middle_transaction.id
    end

    @tag :web
    test "success: returns empty list when no transactions exist", %{conn: conn} do
      bank_account = insert(:bank_account)

      conn = get(conn, ~p"/api/bank_account/#{bank_account.id}/transactions")

      response = json_response(conn, 200)
      assert response["transactions"] == []
    end

    @tag :web
    test "success: paginates results with page and page_size", %{conn: conn} do
      bank_account = insert(:bank_account)

      # Cria 5 transações
      transactions =
        for i <- 1..5 do
          insert(:transaction,
            bank_account_id: bank_account.id,
            account_number: bank_account.account_number,
            amount: i * 10,
            date: DateTime.utc_now() |> DateTime.add(-i, :hour)
          )
        end

      # Ordena por data descendente (mais recente primeiro)
      expected_order = Enum.sort_by(transactions, & &1.date, {:desc, DateTime})

      # Primeira página com 2 itens
      conn =
        get(
          conn,
          ~p"/api/bank_account/#{bank_account.id}/transactions?page=1&page_size=2"
        )

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 2
      assert hd(response["transactions"])["id"] == Enum.at(expected_order, 0).id
      assert Enum.at(response["transactions"], 1)["id"] == Enum.at(expected_order, 1).id

      # Segunda página com 2 itens
      conn =
        get(
          conn,
          ~p"/api/bank_account/#{bank_account.id}/transactions?page=2&page_size=2"
        )

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 2
      assert hd(response["transactions"])["id"] == Enum.at(expected_order, 2).id
      assert Enum.at(response["transactions"], 1)["id"] == Enum.at(expected_order, 3).id
    end

    @tag :web
    test "success: returns first page when only page is provided", %{conn: conn} do
      bank_account = insert(:bank_account)

      # Cria 25 transações
      for i <- 1..25 do
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          amount: i * 10,
          date: DateTime.utc_now() |> DateTime.add(-i, :minute)
        )
      end

      conn =
        get(conn, ~p"/api/bank_account/#{bank_account.id}/transactions?page=2")

      response = json_response(conn, 200)
      assert length(response["transactions"]) == 5
    end

    @tag :web
    test "success: uses custom page_size when only page_size is provided", %{conn: conn} do
      bank_account = insert(:bank_account)

      # Cria 15 transações
      for i <- 1..15 do
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          amount: i * 10,
          date: DateTime.utc_now() |> DateTime.add(-i, :minute)
        )
      end

      conn =
        get(conn, ~p"/api/bank_account/#{bank_account.id}/transactions?page_size=5")

      response = json_response(conn, 200)
      # Deve usar page 1 (padrão) com page_size 5
      assert length(response["transactions"]) == 5
    end

    @tag :web
    test "success: limits page_size to maximum of 100", %{conn: conn} do
      bank_account = insert(:bank_account)

      # Cria 150 transações
      for i <- 1..150 do
        insert(:transaction,
          bank_account_id: bank_account.id,
          account_number: bank_account.account_number,
          amount: i * 10,
          date: DateTime.utc_now() |> DateTime.add(-i, :second)
        )
      end

      conn =
        get(
          conn,
          ~p"/api/bank_account/#{bank_account.id}/transactions?page_size=200"
        )

      response = json_response(conn, 200)
      # Deve limitar a 100 itens
      assert length(response["transactions"]) == 100
    end
  end
end
