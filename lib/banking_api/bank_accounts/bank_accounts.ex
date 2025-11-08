defmodule BankingApi.BankAccounts do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.Repo

  def get(id) do
    case Repo.get(BankAccount, id) do
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
      OpenBankAccount.new()
      |> OpenBankAccount.assign_id(id)
      |> OpenBankAccount.assign_account_number(params["account_number"])
      |> OpenBankAccount.assign_initial_balance(params["initial_balance"])

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(id)
    end
  end

  def close_bank_account(bank_account) do
    command =
      CloseBankAccount.new()
      |> CloseBankAccount.assign_id(bank_account.id)
      |> CloseBankAccount.assign_account_number(bank_account.account_number)

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(bank_account.id)
    end
  end
end
