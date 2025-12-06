defmodule BankingApiWeb.Api.BankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def get(conn, %{"id" => id}) do
    with {:ok, bank_account} <- BankAccounts.get(id) do
      conn
      |> put_status(200)
      |> json(bank_account)
    end
  end
end
