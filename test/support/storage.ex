# test/support/storage.ex
defmodule BankingApi.Storage do
  @doc """
  Clear the event store and read store databases
  """
  def reset! do
    reset_eventstore()
    reset_readstore()
  end

  defp reset_eventstore do
    config = BankingApi.EventStore.config()
    {:ok, conn} = Postgrex.start_link(config)
    EventStore.Storage.Initializer.reset!(conn, config)
  end

  defp reset_readstore do
    config = Application.get_env(:banking_api, BankingApi.Repo)
    {:ok, conn} = Postgrex.start_link(config)
    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
      bank_accounts,
      projection_versions
    RESTART IDENTITY
    CASCADE;
    """
  end
end
