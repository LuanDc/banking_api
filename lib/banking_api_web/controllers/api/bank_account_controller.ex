defmodule BankingApiWeb.Api.BankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  def get(conn, %{"account_number" => account_number}) do
    bank_account = BankAccounts.get_by!(account_number: account_number)

    conn
    |> put_status(200)
    |> json(bank_account)
  end
end
