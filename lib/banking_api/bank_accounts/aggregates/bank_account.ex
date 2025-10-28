defmodule BankingApi.BankAccounts.Aggregates.BankAccount do
  defstruct [:account_number, :balance]

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Events.BankAccountOpened

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  # Public command API

  @impl Aggregate
  def execute(%BankAccount{account_number: nil}, %OpenBankAccount{
        account_number: account_number,
        initial_balance: initial_balance
      })
      when initial_balance > 0 do
    %BankAccountOpened{account_number: account_number, initial_balance: initial_balance}
  end

  # Ensure initial balance is never zero or negative
  @impl Aggregate
  def execute(%BankAccount{}, %OpenBankAccount{initial_balance: initial_balance})
      when initial_balance <= 0 do
    {:error, :initial_balance_must_be_above_zero}
  end

  # Ensure account has not already been opened
  @impl Aggregate
  def execute(%BankAccount{}, %OpenBankAccount{}) do
    {:error, :account_already_opened}
  end

  # State mutators

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountOpened{} = event) do
    %BankAccountOpened{account_number: account_number, initial_balance: initial_balance} = event

    %BankAccount{account | account_number: account_number, balance: initial_balance}
  end
end
