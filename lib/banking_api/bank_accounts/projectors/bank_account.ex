defmodule BankingApi.BankAccounts.Projectors.BankAccount do
  use Commanded.Projections.Ecto,
    application: BankingApi.App,
    repo: BankingApi.Repo,
    name: "BankAccounts.Projectors.BankAccount"

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Projections.BankAccount

  project(
    %BankAccountOpened{account_number: account_number, initial_balance: balance},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :bank_account, %BankAccount{
        account_number: account_number,
        balance: balance
      })
    end
  )
end
