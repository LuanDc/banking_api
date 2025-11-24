defmodule BankingApi.BankAccounts do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.Repo

  # Reader functions

  def get(id) when is_bitstring(id) do
    case Repo.get(BankAccount, id) do
      nil -> {:error, :not_found}
      bank_account -> {:ok, bank_account}
    end
  end

  def get_by(filters) when is_list(filters) do
    case Repo.get_by(BankAccount, filters) do
      nil -> {:error, :not_found}
      bank_account -> {:ok, bank_account}
    end
  end

  def get_by!(filters) when is_list(filters) do
    Repo.get_by!(BankAccount, filters)
  end

  # Writer functions

  def open_bank_account(params) do
    id = Ecto.UUID.generate()

    command =
      params
      |> OpenBankAccount.new()
      |> OpenBankAccount.assign_id(id)

    BankingApiApp.dispatch(command, consistency: :strong)
  end

  def deposit(params) do
    BankingApiApp.dispatch(DepositMoney.new(params), consistency: :strong)
  end

  def withdraw(params) do
    BankingApiApp.dispatch(WithdrawMoney.new(params), consistency: :strong)
  end

  def close_bank_account(params) do
    BankingApiApp.dispatch(CloseBankAccount.new(params), consistency: :strong)
  end
end
