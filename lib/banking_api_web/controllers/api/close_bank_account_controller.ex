defmodule BankingApiWeb.Api.CloseBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    case BankAccounts.close_bank_account(params) do
      {:ok, bank_account} ->
        conn
        |> put_status(201)
        |> json(bank_account)

      {:error, :account_closed} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account closed"})

      error ->
        error
    end
  end
end
