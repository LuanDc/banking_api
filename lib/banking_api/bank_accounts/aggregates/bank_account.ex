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
  alias Commanded.Aggregate.Multi

  @behaviour Aggregate

  # Open Bank Account

  @impl Aggregate
  def execute(
        %BankAccount{account_number: nil} = bank_account,
        %OpenBankAccount{id: id, account_number: account_number, initial_balance: initial_balance}
      ) do
    bank_account
    |> Multi.new()
    |> Multi.execute(fn _ -> bank_account_opened(id, account_number) end)
    |> Multi.execute(fn _ ->
      money_deposited(account_number, initial_balance)
    end)
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
        %BankAccount{status: :open},
        %WithdrawMoney{
          account_number: account_number,
          amount: amount
        }
      ) do
    %MoneyWithdrawn{account_number: account_number, amount: amount}
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

  @impl Aggregate
  def execute(%BankAccount{account_number: nil}, %command{})
      when command in [CloseBankAccount, DepositMoney, WithdrawMoney] do
    {:error, :not_found}
  end

  # Apply Events

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountOpened{} = event) do
    %BankAccountOpened{id: id, account_number: account_number, status: status} =
      event

    %BankAccount{
      account
      | id: id,
        account_number: account_number,
        status: status,
        balance: 0
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

  # Private functions

  defp bank_account_opened(id, account_number) do
    %BankAccountOpened{
      id: id,
      account_number: account_number,
      status: :open
    }
  end

  defp money_deposited(account_number, amount) do
    %MoneyDeposited{
      account_number: account_number,
      amount: amount
    }
  end
end
