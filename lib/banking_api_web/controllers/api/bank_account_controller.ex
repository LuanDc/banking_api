defmodule BankingApiWeb.Api.BankAccountController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts
  alias BankingApi.BankAccounts.Projections.BankAccount

  def get(conn, %{"id" => id}) do
    bank_account = BankAccounts.get_bank_account!(id)

    conn
    |> put_status(200)
    |> json(bank_account)
  end

  def create(conn, params) do
    params
    |> BankAccounts.open_bank_account()
    |> handle_create_response(conn)
  end

  defp handle_create_response(%BankAccount{} = bank_account, conn) do
    conn
    |> put_status(200)
    |> json(bank_account)
  end

  defp handle_create_response({:error, :validation_failure, reason}, conn) do
    conn
    |> put_status(400)
    |> json(reason)
  end

  defp handle_create_response({:error, :initial_balance_must_be_above_zero}, conn) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Initial balance must be above zero"})
  end

  defp handle_create_response({:error, :account_already_opened}, conn) do
    conn
    |> put_status(422)
    |> json(%{"error" => "Account already opened"})
  end
end
