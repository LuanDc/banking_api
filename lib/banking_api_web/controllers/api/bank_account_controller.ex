defmodule BankingApiWeb.Api.BankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def get(conn, %{"id" => id}) do
    with {:ok, bank_account} <- BankAccounts.get(id) do
      conn
      |> put_status(200)
      |> json(bank_account)
    end
  end

  def list_transactions(conn, params) do
    account_number = params["account_number"]
    start_date = parse_date(params["start_date"])
    end_date = parse_date(params["end_date"])

    transactions = BankAccounts.list_transactions(account_number, start_date, end_date)

    conn
    |> put_status(200)
    |> json(%{transactions: transactions})
  end

  defp parse_date(nil), do: nil
  defp parse_date(date_string) when is_binary(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> nil
    end
  end
end
