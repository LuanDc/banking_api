defmodule BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest do
  defstruct [
    :request_id,
    :id,
    :account_number,
    :initial_balance,
    :status,
    :request_status,
    :error
  ]

  alias BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest
  alias BankingApi.BankAccounts.Commands.RequestBankAccountOpening
  alias BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested
  alias BankingApi.BankAccounts.Events.BankAccountOpeningFailed

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  @impl Aggregate
  def execute(
        %BankAccountOpeningRequest{request_id: nil},
        %RequestBankAccountOpening{
          request_id: request_id,
          id: id,
          account_number: account_number,
          initial_balance: initial_balance,
          status: status
        }
      ) do
    %BankAccountOpeningRequested{
      id: id,
      account_number: account_number,
      initial_balance: initial_balance,
      status: status,
      request_id: request_id,
      request_status: :in_progress,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%BankAccountOpeningRequest{}, %RequestBankAccountOpening{}) do
    {:error, :bank_account_opening_already_requested}
  end

  @impl Aggregate
  def execute(
        %BankAccountOpeningRequest{request_id: request_id},
        %MarkBankAccountOpeningAsFailed{request_id: request_id, error_reason: error_reason}
      ) do
    %BankAccountOpeningFailed{
      request_id: request_id,
      error_reason: error_reason,
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%BankAccountOpeningRequest{}, %MarkBankAccountOpeningAsFailed{}) do
    {:error, :request_not_found}
  end

  @impl Aggregate
  def apply(%BankAccountOpeningRequest{} = request, %BankAccountOpeningRequested{} = event) do
    %BankAccountOpeningRequested{
      id: id,
      request_id: request_id,
      account_number: account_number,
      initial_balance: initial_balance,
      status: status
    } = event

    %BankAccountOpeningRequest{
      request
      | id: id,
        request_id: request_id,
        account_number: account_number,
        initial_balance: initial_balance,
        status: status,
        request_status: :in_progress
    }
  end

  @impl Aggregate
  def apply(%BankAccountOpeningRequest{} = request, %BankAccountOpeningFailed{
        error_reason: error_reason
      }) do
    %BankAccountOpeningRequest{
      request
      | request_status: :failed,
        error: error_reason
    }
  end
end
