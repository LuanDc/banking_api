defmodule BankingApiWeb.Api.OpenBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    params
    |> BankAccounts.open_bank_account()
    |> handle_create_response(conn)
  end

  defp handle_create_response({:ok, bank_account}, conn) do
    conn
    |> put_status(200)
    |> json(bank_account)
  end

  defp handle_create_response({:error, :initial_balance_must_be_above_zero}, conn) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Initial balance must be above zero"})
  end

  defp handle_create_response({:error, :account_already_opened}, conn) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Account already opened"})
  end

  defp handle_create_response(error, _conn) do
    error
  end
end
