defmodule BankingApi.BankAccounts.Aggregates.BankAccount do
  defstruct [:id, :account_number, :balance, :status]

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.MoneyDeposited

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  # Open Bank Account

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

  # Close Bank Account

  @impl Aggregate
  def execute(%BankAccount{status: :open}, %CloseBankAccount{
        id: id,
        account_number: account_number
      }) do
    %BankAccountClosed{id: id, account_number: account_number}
  end

  @impl Aggregate
  def execute(%BankAccount{status: :closed}, %CloseBankAccount{}) do
    {:error, :account_already_closed}
  end

  def execute(%BankAccount{status: nil}, %CloseBankAccount{}) do
    {:error, :account_not_open}
  end

  # Deposit Money

  @impl Aggregate
  def execute(
        %BankAccount{status: :open} = bank_account,
        %DepositMoney{
          id: id,
          account_number: account_number,
          amount: amount
        }
      ) do
    new_balance = add_deposit_amount(bank_account.balance, amount)

    if balance_increased?(bank_account.balance, new_balance) do
      %MoneyDeposited{id: id, account_number: account_number, amount: amount}
    else
      {:error, :invalid_deposit_amount}
    end
  end

  # Apply Events

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

  def apply(%BankAccount{} = account, %MoneyDeposited{} = event) do
    %MoneyDeposited{amount: amount} = event

    %BankAccount{account | balance: add_deposit_amount(account.balance, amount)}
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountClosed{} = _event) do
    %BankAccount{account | status: :closed}
  end

  # Private Helpers

  defp balance_increased?(old_balance, new_balance) do
    new_balance > old_balance
  end

  defp add_deposit_amount(balance, amount) do
    balance + amount
  end
end
