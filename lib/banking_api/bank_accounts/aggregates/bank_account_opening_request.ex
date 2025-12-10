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
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested

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
        status: status
    }
  end
end
