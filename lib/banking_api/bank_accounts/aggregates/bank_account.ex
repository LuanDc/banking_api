defmodule BankingApi.BankAccounts.Aggregates.BankAccount do
  defstruct id: nil, account_number: nil, balance: 0, status: nil

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountCreated
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  alias BankingApi.BankAccounts.Events.MoneyWithdrawn

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  # Open Bank Account

  @impl Aggregate
  def execute(%BankAccount{account_number: nil}, %OpenBankAccount{} = command) do
    [
      bank_account_created(command),
      bank_account_opened(command),
      money_deposit(command)
    ]
  end

  @impl Aggregate
  def execute(%BankAccount{}, %OpenBankAccount{initial_balance: initial_balance})
      when initial_balance < 0 do
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

  # Deposit Money

  @impl Aggregate
  def execute(
        %BankAccount{status: :open},
        %DepositMoney{
          account_number: account_number,
          amount: amount
        }
      )
      when amount > 0 do
    %MoneyDeposited{account_number: account_number, amount: amount}
  end

  @impl Aggregate
  def execute(
        %BankAccount{status: :open},
        %DepositMoney{amount: amount}
      )
      when amount <= 0 do
    {:error, :invalid_deposit_amount}
  end

  # Withdraw Money

  @impl Aggregate
  def execute(
        %BankAccount{status: :open, balance: balance},
        %WithdrawMoney{
          id: id,
          account_number: account_number,
          amount: amount
        }
      )
      when amount > 0 and amount <= balance do
    %MoneyWithdrawn{id: id, account_number: account_number, amount: amount}
  end

  @impl Aggregate
  def execute(
        %BankAccount{status: :open},
        %WithdrawMoney{amount: amount}
      )
      when amount <= 0 do
    {:error, :invalid_withdraw_amount}
  end

  @impl Aggregate
  def execute(
        %BankAccount{status: :open, balance: balance},
        %WithdrawMoney{amount: amount}
      )
      when amount > balance do
    {:error, :insufficient_funds}
  end

  # General Restrictions

  @impl Aggregate
  def execute(%BankAccount{status: :closed}, %command{})
      when command in [DepositMoney, WithdrawMoney, CloseBankAccount] do
    {:error, :account_closed}
  end

  # Apply Events

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountCreated{} = event) do
    %BankAccountCreated{id: id, account_number: account_number} = event
    %BankAccount{account | id: id, account_number: account_number}
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountOpened{} = event) do
    %BankAccountOpened{status: status} = event
    %BankAccount{account | status: status}
  end

  def apply(%BankAccount{} = account, %MoneyDeposited{} = event) do
    %MoneyDeposited{amount: amount} = event
    %BankAccount{account | balance: account.balance + amount}
  end

  def apply(%BankAccount{} = account, %MoneyWithdrawn{} = event) do
    %MoneyWithdrawn{amount: amount} = event

    %BankAccount{account | balance: account.balance - amount}
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountClosed{} = _event) do
    %BankAccount{account | status: :closed}
  end

  # Private functions

  defp bank_account_created(%OpenBankAccount{
         id: id,
         account_number: account_number
       }) do
    %BankAccountCreated{
      id: id,
      account_number: account_number
    }
  end

  defp bank_account_opened(%OpenBankAccount{
         account_number: account_number
       }) do
    %BankAccountOpened{
      account_number: account_number,
      status: "open"
    }
  end

  defp money_deposit(%OpenBankAccount{
         account_number: account_number,
         initial_balance: initial_balance
       }) do
    %MoneyDeposited{
      account_number: account_number,
      amount: initial_balance
    }
  end
end
