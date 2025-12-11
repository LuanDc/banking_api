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
  alias BankingApi.BankAccounts.Events.AccountNumberReservationFailed
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested
  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountOpeningError
  alias BankingApi.BankAccounts.Events.BankAccountOpeningCompleted
  alias BankingApi.BankAccounts.ProcessManager.BankAccountOpening

  def interested?(%BankAccountOpeningRequested{request_id: request_id}), do: {:start, request_id}

  def interested?(%AccountNumberReserved{request_id: request_id}), do: {:continue, request_id}

  def interested?(%AccountNumberReservationFailed{request_id: request_id}),
    do: {:continue, request_id}

  def interested?(%BankAccountOpened{request_id: request_id}) when not is_nil(request_id),
    do: {:continue, request_id}

  def interested?(%BankAccountOpened{}), do: false

  def interested?(%BankAccountOpeningError{request_id: request_id}) when not is_nil(request_id),
    do: {:continue, request_id}

  def interested?(%BankAccountOpeningError{}), do: false

  def interested?(%BankAccountOpeningCompleted{request_id: request_id}),
    do: {:stop, request_id}

  def handle(
        %BankAccountOpening{},
        %BankAccountOpeningRequested{
          id: id,
          account_number: account_number,
          request_id: request_id
        }
      ) do
    [
      %ReserveAccountNumber{
        bank_account_id: id,
        account_number: account_number,
        request_id: request_id
      }
    ]
  end

  def handle(
        %BankAccountOpening{
          initial_balance: initial_balance,
          status: status,
          account_number: account_number,
          request_id: request_id
        },
        %AccountNumberReserved{bank_account_id: bank_account_id}
      ) do
    %OpenBankAccount{
      id: bank_account_id,
      account_number: account_number,
      initial_balance: initial_balance,
      status: status,
      request_id: request_id
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

  def handle(%BankAccountOpening{}, %BankAccountOpened{}) do
    []
  end

  def handle(
        %BankAccountOpening{request_id: request_id},
        %AccountNumberReservationFailed{error_reason: error_reason}
      )
      when not is_nil(request_id) do
    %MarkBankAccountOpeningAsFailed{
      request_id: request_id,
      error_reason: error_reason
    }
  end

  def handle(%BankAccountOpening{}, %AccountNumberReservationFailed{}) do
    []
  end

  def handle(
        %BankAccountOpening{request_id: request_id},
        %BankAccountOpeningError{error_reason: error_reason}
      )
      when not is_nil(request_id) do
    %MarkBankAccountOpeningAsFailed{
      request_id: request_id,
      error_reason: error_reason
    }
  end

  def handle(%BankAccountOpening{}, %BankAccountOpeningError{}) do
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

  def apply(%BankAccountOpening{} = state, %AccountNumberReservationFailed{}) do
    state
  end

  def apply(%BankAccountOpening{} = state, %BankAccountOpeningError{}) do
    state
  end

  def error(error, _failed_message, _context) do
    Logger.alert(
      fn ->
        """
        Unexpected error was identified by BankAccountOpening process manager. Please, implement this error handler to dispatch MarkBankAccountOpeningAsFailed.
        """
      end,
      error: error
    )

    {:stop, error}
  end
end
