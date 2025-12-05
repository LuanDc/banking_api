defmodule BankingApiWeb.Api.BankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def get(conn, %{"account_number" => account_number}) do
    with {:ok, bank_account} <- BankAccounts.get_by(account_number: account_number) do
      conn
      |> put_status(200)
      |> json(bank_account)
    end
  end
end
