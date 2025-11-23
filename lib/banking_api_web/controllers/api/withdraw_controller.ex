defmodule BankingApiWeb.Api.WithdrawController do
  use BankingApiWeb, :controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    case BankAccounts.withdraw(params) do
      {:ok, bank_account} ->
        conn
        |> put_status(201)
        |> json(bank_account)

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
