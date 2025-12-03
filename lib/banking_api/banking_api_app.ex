defmodule BankingApi.BankingApiApp do
  use Commanded.Application, otp_app: :banking_api

  require Logger

  router(BankingApi.Router)

  def dispatch(commands) when is_list(commands) do
    Enum.reduce_while(commands, :ok, fn command, :ok ->
      case dispatch(command, consistency: :strong) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end
end
