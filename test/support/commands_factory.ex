defmodule BankingApi.CommandsFactory do
  alias BankingApi.BankAccounts.Commands.{
    OpenBankAccount,
    DepositMoney,
    WithdrawMoney,
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
      bank_account_id: Keyword.get(opts, :bank_account_id, Ecto.UUID.generate()),
      amount: Keyword.get(opts, :amount, 100)
    }
    |> Map.merge(Map.new(opts))
  end

  def build_command(%WithdrawMoney{}, opts) do
    %WithdrawMoney{
      bank_account_id: Keyword.get(opts, :bank_account_id, Ecto.UUID.generate()),
      amount: Keyword.get(opts, :amount, 50)
    }
    |> Map.merge(Map.new(opts))
  end

  def build_command(%UpdateBankAccountStatus{}, opts) do
    %UpdateBankAccountStatus{
      bank_account_id: Keyword.get(opts, :bank_account_id, Ecto.UUID.generate()),
      status: Keyword.get(opts, :status, "inactive")
    }
    |> Map.merge(Map.new(opts))
  end

  defp generate_account_number do
    "#{Enum.random(1000..9999)}-#{Enum.random(10..99)}"
  end
end
