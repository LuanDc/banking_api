defmodule BankingApi.BankAccounts.Aggregates.BankAccount do
  defstruct [:id, :account_number, :balance, :status]

  alias BankingApi.BankAccounts.Aggregates.BankAccount
  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  @impl Aggregate
  def execute(%BankAccount{account_number: nil}, %OpenBankAccount{
        id: id,
        account_number: account_number,
        initial_balance: initial_balance
      })
      when initial_balance > 0 do
    %BankAccountOpened{id: id, account_number: account_number, initial_balance: initial_balance}
  end

  @impl Aggregate
  def execute(%BankAccount{}, %OpenBankAccount{initial_balance: initial_balance})
      when initial_balance <= 0 do
    {:error, :initial_balance_must_be_above_zero}
  end

  @impl Aggregate
  def execute(%BankAccount{id: id}, %OpenBankAccount{}) when is_binary(id) do
    {:error, :account_already_opened}
  end

  @impl Aggregate
  def execute(%BankAccount{status: :open}, %CloseBankAccount{
        id: id,
        account_number: account_number
      })
      when is_binary(id) do
    %BankAccountClosed{id: id, account_number: account_number}
  end

  @impl Aggregate
  def execute(%BankAccount{status: :closed}, %CloseBankAccount{}) do
    {:error, :account_already_closed}
  end

  def execute(%BankAccount{status: nil}, %CloseBankAccount{}) do
    {:error, :account_not_open}
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountOpened{} = event) do
    %BankAccountOpened{id: id, account_number: account_number, initial_balance: initial_balance} =
      event

    %BankAccount{
      account
      | id: id,
        account_number: account_number,
        balance: initial_balance,
        status: :open
    }
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountClosed{} = _event) do
    %BankAccount{account | status: :closed}
  end
end
