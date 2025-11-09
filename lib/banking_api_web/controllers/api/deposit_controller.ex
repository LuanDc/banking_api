defmodule BankingApiWeb.Api.DepositController do
  use BankingApiWeb, :controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, %{"account_number" => account_number} = params) do
    bank_account = BankAccounts.get_by!(account_number: account_number)

    case BankAccounts.deposit(bank_account, params) do
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
