defmodule BankingApi.BankAccounts do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.Repo

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

  def deposit(bank_account, params) do
    command =
      DepositMoney.new()
      |> DepositMoney.assign_id(bank_account.id)
      |> DepositMoney.assign_account_number(params["account_number"])
      |> DepositMoney.assign_amount(params["amount"])

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(bank_account.id)
    end
  end

  def withdraw(bank_account, params) do
    command =
      WithdrawMoney.new()
      |> WithdrawMoney.assign_id(bank_account.id)
      |> WithdrawMoney.assign_account_number(params["account_number"])
      |> WithdrawMoney.assign_amount(params["amount"])

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(bank_account.id)
    end
  end

  def close_bank_account(params) do
    response = BankingApiApp.dispatch(CloseBankAccount.new(params), consistency: :strong)

    if dispatched_successfully?(response) or
         is_account_closed?(response) do
      get_by(account_number: params["account_number"])
    else
      response
    end
  end

  defp dispatched_successfully?(:ok), do: true
  defp dispatched_successfully?({:error, _}), do: false

  defp is_account_closed?({:error, :account_closed}), do: true
  defp is_account_closed?({:error, _}), do: false
end
