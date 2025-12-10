defmodule BankingApiWeb.Api.BankAccountOpeningRequestController do
  use Phoenix.Controller

  alias BankingApi.BankAccounts

  action_fallback BankingApiWeb.FallbackController

  def show(conn, %{"request_id" => request_id}) do
    with {:ok, request} <- BankAccounts.get_opening_request(request_id) do
      conn
      |> put_status(200)
      |> json(request)
    end
  end
end
