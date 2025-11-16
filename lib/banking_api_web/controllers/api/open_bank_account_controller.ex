defmodule BankingApiWeb.Api.OpenBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    case BankAccounts.open_bank_account(params) do
      {:ok, bank_account} ->
        conn
        |> put_status(200)
        |> json(bank_account)

      {:error, :account_already_opened} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account already opened"})

      error ->
        error
    end
  end
end
