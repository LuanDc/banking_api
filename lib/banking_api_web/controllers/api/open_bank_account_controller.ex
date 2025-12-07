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
      {:error, :account_already_opened} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account already opened"})

      {:error, :account_number_already_taken} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Account number already taken"})

      error ->
        error
    end
  end
end
