defmodule BankingApiWeb.Api.WithdrawController do
  use BankingApiWeb, :controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, %{"account_number" => account_number} = params) do
    bank_account = BankAccounts.get_by!(account_number: account_number)

    case BankAccounts.withdraw(bank_account, params) do
      {:ok, bank_account} ->
        conn
        |> put_status(201)
        |> json(bank_account)

      {:error, :insufficient_funds} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Insufficient funds"})

      error ->
        error
    end
  end
end
