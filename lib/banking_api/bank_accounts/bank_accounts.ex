defmodule BankingApi.BankAccounts do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.Repo

  def get_bank_account!(id), do: Repo.get!(BankAccount, id)

  def open_bank_account(params) do
    id = Ecto.UUID.generate()

    command =
      OpenBankAccount.new()
      |> OpenBankAccount.assign_id(id)
      |> OpenBankAccount.assign_account_number(params["account_number"])
      |> OpenBankAccount.assign_initial_balance(params["initial_balance"])

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      Repo.get(BankAccount, id)
    end
  end
end
