defmodule BankingApi.BankAccounts.Aggregates.BankAccount do
  defstruct [:id, :account_number, :balance, :status]

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  alias BankingApi.BankAccounts.Events.MoneyWithdrawn

  alias Commanded.Aggregates.Aggregate

  @behaviour Aggregate

  # Open Bank Account

  @impl Aggregate
  def execute(
        %BankAccount{account_number: nil},
        %OpenBankAccount{id: id, account_number: account_number, initial_balance: initial_balance}
      ) do
    %BankAccountOpened{
      id: id,
      account_number: account_number,
      initial_balance: initial_balance,
      status: :open
    }
  end

  @impl Aggregate
  def execute(%BankAccount{}, %OpenBankAccount{}) do
    {:error, :account_already_opened}
  end

  # Close Bank Account

  @impl Aggregate
  def execute(%BankAccount{account_number: account_number, status: :open}, %CloseBankAccount{
        account_number: account_number
      })
      when not is_nil(account_number) do
    %BankAccountClosed{account_number: account_number, status: :closed}
  end

  # Deposit Money

  @impl Aggregate
  def execute(
        %BankAccount{status: :open},
        %DepositMoney{
          account_number: account_number,
          amount: amount
        }
      ) do
    money_deposited(account_number, amount)
  end

  # Withdraw Money

  @impl Aggregate
  def execute(
        %BankAccount{status: :open} = bank_account,
        %WithdrawMoney{
          account_number: account_number,
          amount: amount
        }
      )
      when amount <= bank_account.balance do
    %MoneyWithdrawn{account_number: account_number, amount: amount}
  end

  @impl Aggregate
  def execute(
        %BankAccount{status: :open},
        %WithdrawMoney{}
      ) do
    {:error, :insufficient_funds}
  end

  # General Restrictions

  @impl Aggregate
  def execute(%BankAccount{status: :closed}, %command{})
      when command in [DepositMoney, WithdrawMoney, CloseBankAccount] do
    {:error, :account_closed}
  end

  @impl Aggregate
  def execute(%BankAccount{account_number: nil}, %command{})
      when command in [CloseBankAccount, DepositMoney, WithdrawMoney] do
    {:error, :not_found}
  end

  # Apply Events

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountOpened{} = event) do
    %BankAccountOpened{
      id: id,
      account_number: account_number,
      status: status,
      initial_balance: initial_balance
    } =
      event

    %BankAccount{
      account
      | id: id,
        account_number: account_number,
        status: status,
        balance: initial_balance
    }
  end

  def apply(%BankAccount{balance: balance} = account, %MoneyDeposited{} = event) do
    %MoneyDeposited{amount: amount} = event
    %BankAccount{account | balance: balance + amount}
  end

  def apply(%BankAccount{balance: balance} = account, %MoneyWithdrawn{} = event) do
    %MoneyWithdrawn{amount: amount} = event
    %BankAccount{account | balance: balance - amount}
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountClosed{} = _event) do
    %BankAccount{account | status: :closed}
  end

  defp money_deposited(account_number, amount) do
    %MoneyDeposited{
      account_number: account_number,
      amount: amount
    }
  end
end
