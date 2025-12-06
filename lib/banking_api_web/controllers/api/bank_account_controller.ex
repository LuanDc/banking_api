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
    id = params["id"]
    start_date = parse_date(params["start_date"])
    end_date = parse_date(params["end_date"])
    page = parse_integer(params["page"])
    page_size = parse_integer(params["page_size"])

    opts =
      []
      |> maybe_add_opt(:start_date, start_date)
      |> maybe_add_opt(:end_date, end_date)
      |> maybe_add_opt(:page, page)
      |> maybe_add_opt(:page_size, page_size)

    transactions = BankAccounts.list_transactions(id, opts)

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

  defp parse_integer(nil), do: nil

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, _} -> integer
      :error -> nil
    end
  end

  defp parse_integer(value) when is_integer(value), do: value

  defp maybe_add_opt(opts, _key, nil), do: opts
  defp maybe_add_opt(opts, key, value), do: Keyword.put(opts, key, value)
end
