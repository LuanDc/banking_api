defmodule BankingApiWeb.Api.OpenBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    with {:ok, bank_account} <- BankAccounts.open_bank_account(params) do
      conn
      |> put_status(201)
      |> json(bank_account)
    else
      error -> parse_error(conn, error)
    end
  end

  defp parse_error(conn, {:error, :account_already_opened}) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Account already opened"})
  end

  defp parse_error(conn, {:error, :account_number_already_taken}) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Account number already taken"})
  end

  defp parse_error(conn, {:error, :duplicated_account_number}) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Account number already taken"})
  end

  defp parse_error(_conn, error) do
    error
  end
end
