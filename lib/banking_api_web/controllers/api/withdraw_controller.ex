defmodule BankingApiWeb.Api.WithdrawController do
  use BankingApiWeb, :controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    with {:ok, bank_account} <- BankAccounts.withdraw(params) do
      conn
      |> put_status(201)
      |> json(bank_account)
    else
      {:error, :insufficient_funds} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Insufficient funds"})

      {:error, :account_closed} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account closed"})

      error ->
        error
    end
  end
end
