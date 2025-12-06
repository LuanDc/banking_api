defmodule BankingApi.BankAccounts.Aggregates.BankAccount do
  defstruct [:id, :account_number, :balance, :status]

  alias BankingApi.BankAccounts.Aggregates.BankAccount

  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.BankAccountStatusUpdated
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
      status: "active",
      date: DateTime.utc_now()
    }
  end

  @impl Aggregate
  def execute(%BankAccount{}, %OpenBankAccount{}) do
    {:error, :account_already_opened}
  end

  # Update Bank Account Status

  @impl Aggregate
  def execute(
        %BankAccount{id: bank_account_id, status: current_status},
        %UpdateBankAccountStatus{status: new_status}
      )
      when not is_nil(bank_account_id) and current_status != new_status do
    %BankAccountStatusUpdated{bank_account_id: bank_account_id, status: new_status}
  end

  @impl Aggregate
  def execute(
        %BankAccount{status: current_status},
        %UpdateBankAccountStatus{status: current_status}
      ) do
    {:error, :status_already_set}
  end

  # Deposit Money

  @impl Aggregate
  def execute(
        %BankAccount{status: "active", id: bank_account_id},
        %DepositMoney{amount: amount}
      )
      when not is_nil(bank_account_id) do
    money_deposited(bank_account_id, amount)
  end

  # Withdraw Money

  @impl Aggregate
  def execute(
        %BankAccount{status: "active", id: bank_account_id} = bank_account,
        %WithdrawMoney{amount: amount}
      )
      when not is_nil(bank_account_id) and amount <= bank_account.balance do
    %MoneyWithdrawn{bank_account_id: bank_account_id, amount: amount, date: DateTime.utc_now()}
  end

  @impl Aggregate
  def execute(
        %BankAccount{status: "active", id: bank_account_id},
        %WithdrawMoney{}
      )
      when not is_nil(bank_account_id) do
    {:error, :insufficient_funds}
  end

  # General Restrictions

  @impl Aggregate
  def execute(%BankAccount{status: "inactive"}, %command{})
      when command in [DepositMoney, WithdrawMoney, CloseBankAccount] do
    {:error, :account_closed}
  end

  @impl Aggregate
  def execute(%BankAccount{id: nil}, %command{})
      when command in [CloseBankAccount, DepositMoney, WithdrawMoney, UpdateBankAccountStatus] do
    {:error, :not_found}
  end

  @impl Aggregate
  def execute(%BankAccount{account_number: nil}, %command{})
      when command in [CloseBankAccount, DepositMoney, WithdrawMoney, UpdateBankAccountStatus] do
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
    %BankAccount{account | status: "inactive"}
  end

  @impl Aggregate
  def apply(%BankAccount{} = account, %BankAccountStatusUpdated{} = event) do
    %BankAccountStatusUpdated{status: status} = event
    %BankAccount{account | status: status}
  end

  defp money_deposited(bank_account_id, amount) do
    %MoneyDeposited{
      bank_account_id: bank_account_id,
      amount: amount,
      date: DateTime.utc_now()
    }
  end
end
