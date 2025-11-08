defmodule BankingApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BankingApiWeb.Telemetry,
      BankingApi.BankingApiApp,
      BankingApi.Repo,
      BankingApi.BankAccounts.Supervisor,
      {DNSCluster, query: Application.get_env(:banking_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BankingApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BankingApi.Finch},
      # Start a worker by calling: BankingApi.Worker.start_link(arg)
      # {BankingApi.Worker, arg},
      # Start to serve requests, typically the last entry
      BankingApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankingApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BankingApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
