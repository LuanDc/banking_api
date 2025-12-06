defmodule BankingApi.BankAccounts do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus
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

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(id)
    end
  end

  def deposit(params) do
    with :ok <- BankingApiApp.dispatch(DepositMoney.new(params), consistency: :strong) do
      get(params["id"])
    end
  end

  def withdraw(params) do
    with :ok <- BankingApiApp.dispatch(WithdrawMoney.new(params), consistency: :strong) do
      get(params["id"])
    end
  end

  def update_bank_account_status(params) do
    with :ok <-
           BankingApiApp.dispatch(UpdateBankAccountStatus.new(params), consistency: :strong) do
      get(params["id"])
    end
  end
end
