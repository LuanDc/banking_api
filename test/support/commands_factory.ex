defmodule BankingApi.CommandsFactory do
  alias BankingApi.BankAccounts.Commands.{
    OpenBankAccount,
    DepositMoney,
    WithdrawMoney,
    CloseBankAccount,
    UpdateBankAccountStatus
  }

  def build_command(command, opts \\ [])

  def build_command(%OpenBankAccount{}, opts) do
    %OpenBankAccount{
      id: Keyword.get(opts, :id, Ecto.UUID.generate()),
      account_number: Keyword.get(opts, :account_number, generate_account_number()),
      initial_balance: Keyword.get(opts, :initial_balance, 0),
      status: Keyword.get(opts, :status, "active")
    }
    |> Map.merge(Map.new(opts))
  end

  def build_command(%DepositMoney{}, opts) do
    %DepositMoney{
      account_number: Keyword.get(opts, :account_number, generate_account_number()),
      amount: Keyword.get(opts, :amount, 100)
    }
    |> Map.merge(Map.new(opts))
  end

  def build_command(%WithdrawMoney{}, opts) do
    %WithdrawMoney{
      account_number: Keyword.get(opts, :account_number, generate_account_number()),
      amount: Keyword.get(opts, :amount, 50)
    }
    |> Map.merge(Map.new(opts))
  end

  def build_command(%CloseBankAccount{}, opts) do
    %CloseBankAccount{
      account_number: Keyword.get(opts, :account_number, generate_account_number())
    }
    |> Map.merge(Map.new(opts))
  end

  def build_command(%UpdateBankAccountStatus{}, opts) do
    %UpdateBankAccountStatus{
      account_number: Keyword.get(opts, :account_number, generate_account_number()),
      status: Keyword.get(opts, :status, "inactive")
    }
    |> Map.merge(Map.new(opts))
  end

  defp generate_account_number do
    "#{Enum.random(1000..9999)}-#{Enum.random(10..99)}"
  end
end
