defmodule BankingApiWeb.FallbackController do
  use Phoenix.Controller

  require Logger

  def call(conn, {:error, :validation_failure, reason}) do
    conn
    |> put_status(400)
    |> json(%{"error" => reason})
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> json(%{"error" => "Not found!"})
  end

  def call(conn, {:error, _reason} = error) do
    Logger.error("Internal server error: #{inspect(error)}")

    conn
    |> put_status(500)
    |> json(%{"error" => "Internal server error"})
  end
end
