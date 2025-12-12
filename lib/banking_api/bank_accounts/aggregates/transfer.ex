defmodule BankingApi.BankAccounts.Aggregates.Transfer do
  defstruct [
    :id,
    :request_id,
    :from_account_id,
    :to_account_id,
    :amount,
    :status
  ]

  alias BankingApi.BankAccounts.Aggregates.Transfer
  alias BankingApi.BankAccounts.Commands.InitiateTransfer
  alias BankingApi.BankAccounts.Commands.CompleteTransfer
  alias BankingApi.BankAccounts.Commands.ReceiveTransfer
  alias BankingApi.BankAccounts.Events.TransferInitiated
  alias BankingApi.BankAccounts.Events.TransferCompleted
  alias BankingApi.BankAccounts.Events.TransferReceived
  alias BankingApi.BankAccounts.Events.TransferFailed

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  # Inicia a transferência
  @impl Aggregate
  def execute(
        %Transfer{request_id: nil},
        %InitiateTransfer{
          request_id: request_id,
          id: id,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        }
      ) do
    %TransferInitiated{
      id: id,
      request_id: request_id,
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      amount: amount,
      status: :initiated,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%Transfer{}, %InitiateTransfer{}) do
    {:error, :transfer_already_initiated}
  end

  # Completa a transferência (débito da conta origem)
  @impl Aggregate
  def execute(
        %Transfer{
          id: id,
          status: :initiated,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        },
        %CompleteTransfer{id: id}
      ) do
    %TransferCompleted{
      id: id,
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      amount: amount,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%Transfer{status: status}, %CompleteTransfer{})
      when status != :initiated do
    {:error, :transfer_not_in_initiated_status}
  end

  @impl Aggregate
  def execute(%Transfer{}, %CompleteTransfer{}) do
    {:error, :transfer_not_found}
  end

  # Recebe a transferência (crédito na conta destino)
  @impl Aggregate
  def execute(
        %Transfer{
          id: id,
          status: :completed,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        },
        %ReceiveTransfer{id: id}
      ) do
    %TransferReceived{
      id: id,
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      amount: amount,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%Transfer{status: status}, %ReceiveTransfer{})
      when status != :completed do
    {:error, :transfer_not_completed}
  end

  @impl Aggregate
  def execute(%Transfer{}, %ReceiveTransfer{}) do
    {:error, :transfer_not_found}
  end

  # Apply TransferInitiated
  @impl Aggregate
  def apply(%Transfer{} = transfer, %TransferInitiated{} = event) do
    %TransferInitiated{
      id: id,
      request_id: request_id,
      from_account_id: from_account_id,
      to_account_id: to_account_id,
      amount: amount
    } = event

    %Transfer{
      transfer
      | id: id,
        request_id: request_id,
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        amount: amount,
        status: :initiated
    }
  end

  # Apply TransferCompleted
  @impl Aggregate
  def apply(%Transfer{} = transfer, %TransferCompleted{}) do
    %Transfer{transfer | status: :completed}
  end

  # Apply TransferReceived
  @impl Aggregate
  def apply(%Transfer{} = transfer, %TransferReceived{}) do
    %Transfer{transfer | status: :received}
  end

  # Apply TransferFailed
  @impl Aggregate
  def apply(%Transfer{} = transfer, %TransferFailed{}) do
    %Transfer{transfer | status: :failed}
  end
end
