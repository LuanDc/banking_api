defmodule BankingApiWeb.Api.UpdateBankAccountStatusController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def create(conn, params) do
    with {:ok, bank_account} <- BankAccounts.update_bank_account_status(params) do
      conn
      |> put_status(200)
      |> json(bank_account)
    else
      {:error, :status_already_set} ->
        conn
        |> put_status(422)
        |> json(%{"error" => "Status already set"})

      error ->
        error
    end
  end
end
