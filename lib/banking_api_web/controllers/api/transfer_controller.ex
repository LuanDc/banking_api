defmodule BankingApiWeb.Api.TransferController do
  use BankingApiWeb, :controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    with {:ok, bank_account} <- BankAccounts.transfer(params) do
      conn
      |> put_status(201)
      |> json(bank_account)
    else
      {:error, :account_closed} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account closed"})

      {:error, :insufficient_funds} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Insufficient funds"})

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> json(%{"error" => "Account not found"})

      error ->
        error
    end
  end
end
