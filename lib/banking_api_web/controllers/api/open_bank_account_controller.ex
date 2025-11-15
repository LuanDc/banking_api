defmodule BankingApiWeb.Api.OpenBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    response = BankAccounts.open_bank_account(params)

    case response do
      :ok ->
        conn
        |> put_status(200)
        |> text("")

      {:error, :account_already_opened} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account already opened"})

      error ->
        error
    end
  end
end
