defmodule BankingApiWeb.Api.CloseBankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    with {:ok, bank_account} <- BankAccounts.close_bank_account(params) do
      conn
      |> put_status(201)
      |> json(bank_account)
    end
  end
end
