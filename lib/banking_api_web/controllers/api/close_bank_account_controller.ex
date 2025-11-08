defmodule BankingApiWeb.Api.CloseBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  def create(conn, %{"account_number" => account_number}) do
    bank_account = BankAccounts.get_by!(account_number: account_number)

    case BankAccounts.close_bank_account(bank_account) do
      {:ok, bank_account} ->
        conn
        |> put_status(201)
        |> json(bank_account)

      {:error, :account_already_closed} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Bank account already closed"})
    end
  end
end
