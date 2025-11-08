defmodule BankingApi.BankAccounts.Projectors.BankAccount do
  use Commanded.Projections.Ecto,
    application: BankingApi.BankingApiApp,
    repo: BankingApi.Repo,
    name: "BankAccounts.Projectors.BankAccount",
    consistency: :strong

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Projections.BankAccount

  project(
    %BankAccountOpened{id: id, account_number: account_number, initial_balance: balance},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :bank_account, %BankAccount{
        id: id,
        account_number: account_number,
        balance: balance
      })
    end
  )
end
