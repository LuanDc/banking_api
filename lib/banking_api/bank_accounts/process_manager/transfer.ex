defmodule BankingApi.BankAccounts.ProcessManager.Transfer do
  use Commanded.ProcessManagers.ProcessManager,
    application: BankingApi.BankingApiApp,
    name: __MODULE__,
    consistency: :strong

  defstruct [:id, :request_id, :from_account_id, :to_account_id, :amount, :status]

  alias BankingApi.BankAccounts.ProcessManager.Transfer

  alias BankingApi.BankAccounts.Commands.CompleteTransfer
  alias BankingApi.BankAccounts.Commands.ReceiveTransfer

  alias BankingApi.BankAccounts.Events.TransferInitiated
  alias BankingApi.BankAccounts.Events.TransferCompleted
  alias BankingApi.BankAccounts.Events.TransferReceived
  alias BankingApi.BankAccounts.Events.TransferFailed

  # Define interesse nos eventos
  def interested?(%TransferInitiated{request_id: request_id}), do: {:start, request_id}

  def interested?(%TransferCompleted{id: id}) when not is_nil(id), do: {:continue, id}

  def interested?(%TransferReceived{id: id}) when not is_nil(id), do: {:stop, id}

  def interested?(%TransferFailed{request_id: request_id}), do: {:stop, request_id}

  def interested?(_event), do: false

  # Quando a transferência é iniciada, dispara o comando para completar (débito)
  def handle(
        %Transfer{},
        %TransferInitiated{
          id: id,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        }
      ) do
    [
      %CompleteTransfer{
        id: id,
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        amount: amount
      }
    ]
  end

  # Quando a transferência é completada (débito realizado), dispara o recebimento (crédito)
  def handle(
        %Transfer{},
        %TransferCompleted{
          id: id,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        }
      ) do
    [
      %ReceiveTransfer{
        id: id,
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        amount: amount
      }
    ]
  end

  # Quando a transferência é recebida, o processo termina (handled by interested?)
  def handle(%Transfer{}, %TransferReceived{}), do: []

  # Quando há erro, o processo termina
  def handle(%Transfer{}, %TransferFailed{}), do: []

  # Atualiza o estado interno do Process Manager
  def apply(
        %Transfer{} = state,
        %TransferInitiated{
          id: id,
          request_id: request_id,
          from_account_id: from_account_id,
          to_account_id: to_account_id,
          amount: amount
        }
      ) do
    %Transfer{
      state
      | id: id,
        request_id: request_id,
        from_account_id: from_account_id,
        to_account_id: to_account_id,
        amount: amount,
        status: :initiated
    }
  end

  def apply(%Transfer{} = state, %TransferCompleted{}) do
    %Transfer{state | status: :completed}
  end

  def apply(%Transfer{} = state, %TransferReceived{}) do
    %Transfer{state | status: :received}
  end

  def apply(%Transfer{} = state, %TransferFailed{}) do
    %Transfer{state | status: :failed}
  end

  # Tratamento de erros
  def error({:error, reason}, %TransferInitiated{} = event, _failure_context) do
    %TransferFailed{
      id: event.id,
      request_id: event.request_id,
      from_account_id: event.from_account_id,
      error_reason: inspect(reason),
      date: DateTime.utc_now()
    }
  end

  def error({:error, reason}, %TransferCompleted{} = event, _failure_context) do
    %TransferFailed{
      id: event.id,
      request_id: nil,
      from_account_id: event.from_account_id,
      error_reason: inspect(reason),
      date: DateTime.utc_now()
    }
  end

  def error(error, _event, _failure_context) do
    IO.inspect(error, label: "Transfer Process Manager Error")
    :skip
  end
end
