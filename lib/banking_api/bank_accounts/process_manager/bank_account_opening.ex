defmodule BankingApi.BankAccounts.ProcessManager.BankAccountOpening do
  use Commanded.ProcessManagers.ProcessManager,
    application: BankingApi.BankingApiApp,
    name: __MODULE__,
    consistency: :strong

  @derive Jason.Encoder
  defstruct [:id, :initial_balance, :status, :account_number, :request_id]

  require Logger

  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.ReserveAccountNumber
  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed
  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsCompleted
  alias BankingApi.BankAccounts.Events.AccountNumberReserved
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested
  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountOpeningCompleted
  alias BankingApi.BankAccounts.ProcessManager.BankAccountOpening

  def interested?(%BankAccountOpeningRequested{id: id}), do: {:start, id}
  def interested?(%AccountNumberReserved{bank_account_id: id}), do: {:continue, id}
  def interested?(%BankAccountOpened{id: id}), do: {:continue, id}
  def interested?(%BankAccountOpeningCompleted{bank_account_id: id}), do: {:stop, id}

  def handle(
        %BankAccountOpening{},
        %BankAccountOpeningRequested{
          id: id,
          account_number: account_number
        }
      ) do
    [
      %ReserveAccountNumber{
        bank_account_id: id,
        account_number: account_number
      }
    ]
  end

  def handle(
        %BankAccountOpening{
          initial_balance: initial_balance,
          status: status,
          account_number: account_number
        },
        %AccountNumberReserved{bank_account_id: bank_account_id}
      ) do
    %OpenBankAccount{
      id: bank_account_id,
      account_number: account_number,
      initial_balance: initial_balance,
      status: status
    }
  end

  def handle(
        %BankAccountOpening{request_id: request_id},
        %BankAccountOpened{}
      )
      when not is_nil(request_id) do
    %MarkBankAccountOpeningAsCompleted{
      request_id: request_id
    }
  end

  def handle(%BankAccountOpening{request_id: nil}, %BankAccountOpened{}) do
    []
  end

  def handle(%BankAccountOpening{}, %BankAccountOpeningCompleted{}) do
    []
  end

  def apply(
        %BankAccountOpening{} = state,
        %BankAccountOpeningRequested{
          id: id,
          request_id: request_id,
          account_number: account_number,
          initial_balance: initial_balance,
          status: status
        }
      ) do
    %BankAccountOpening{
      state
      | id: id,
        request_id: request_id,
        account_number: account_number,
        initial_balance: initial_balance,
        status: status
    }
  end

  def apply(%BankAccountOpening{} = state, %AccountNumberReserved{}) do
    state
  end

  def apply(%BankAccountOpening{} = state, %BankAccountOpened{}) do
    state
  end

  def apply(%BankAccountOpening{} = state, %BankAccountOpeningCompleted{}) do
    state
  end

  def error({:error, _failure}, _failed_message, %{context: %{failures: failures}})
      when failures >= 2 do
    {:stop, :too_many_failures}
  end

  def error(
        {:error, :account_number_already_reserved},
        _command_or_event,
        %{state: %{id: id, request_id: _request_id}}
      ) do
    Logger.alert(fn ->
      "#{__MODULE__} account number already reserved. Marking request as failed."
    end)

    %MarkBankAccountOpeningAsFailed{
      id: id,
      error_reason: inspect(:account_number_already_reserved)
    }
  end

  def error({:error, reason}, _command_or_event, %{state: %{id: id, request_id: request_id}})
      when not is_nil(request_id) do
    Logger.error(fn -> "#{__MODULE__} encountered an error: " <> inspect(reason) end)

    %MarkBankAccountOpeningAsFailed{
      id: id,
      error_reason: inspect(reason)
    }
  end

  def error(error, _command_or_event, _failure_context) do
    Logger.error(fn -> "#{__MODULE__} encountered an error: " <> inspect(error) end)

    :skip
  end
end
