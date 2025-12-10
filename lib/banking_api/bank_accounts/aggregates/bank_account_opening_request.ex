defmodule BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest do
  defstruct [:id, :account_number, :initial_balance, :status]

  alias BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest
  alias BankingApi.BankAccounts.Commands.RequestBankAccountOpening
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  @impl Aggregate
  def execute(
        %BankAccountOpeningRequest{id: nil},
        %RequestBankAccountOpening{
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
      account_number: account_number,
      initial_balance: initial_balance,
      status: status
    } = event

    %BankAccountOpeningRequest{
      request
      | id: id,
        account_number: account_number,
        initial_balance: initial_balance,
        status: status
    }
  end
end
