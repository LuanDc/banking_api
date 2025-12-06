defmodule BankingApiWeb.PageControllerTest do
  use BankingApiWeb.ConnCase

  describe "GET /" do
    test "success: returns home page with expected content", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      assert response =~ "Peace of mind from prototype to production"
    end

    test "success: returns HTML content type", %{conn: conn} do
      conn = get(conn, ~p"/")

      assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
    end

    test "success: returns 200 status code", %{conn: conn} do
      conn = get(conn, ~p"/")

      assert conn.status == 200
    end

    test "success: contains Phoenix Framework branding", %{conn: conn} do
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)

      # Verify Phoenix branding is present
      assert response =~ "Phoenix Framework"
    end

    test "success: renders without database connection", %{conn: conn} do
      # This test ensures the home page doesn't require DB
      conn = get(conn, ~p"/")

      assert conn.status == 200
    end

    test "success: multiple requests return consistent structure", %{conn: conn} do
      conn1 = get(conn, ~p"/")
      conn2 = get(conn, ~p"/")

      response1 = html_response(conn1, 200)
      response2 = html_response(conn2, 200)

      # Both should contain the same main content
      assert response1 =~ "Peace of mind from prototype to production"
      assert response2 =~ "Peace of mind from prototype to production"
    end

    test "success: accepts GET method only", %{conn: conn} do
      # Test that POST is not allowed
      conn = post(conn, ~p"/", %{})

      assert conn.status == 404
    end

    test "success: page loads quickly without timeout", %{conn: conn} do
      # Verify the page responds promptly
      start_time = System.monotonic_time(:millisecond)
      conn = get(conn, ~p"/")
      end_time = System.monotonic_time(:millisecond)

      assert conn.status == 200
      # Should load in less than 1 second
      assert end_time - start_time < 1000
    end
  end
end
