defmodule BankingApiWeb.Api.DepositController do
  use BankingApiWeb, :controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    case BankAccounts.deposit(params) do
      :ok ->
        conn
        |> put_status(201)
        |> text("")

      {:error, :account_closed} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account closed"})

      error ->
        error
    end
  end
end
