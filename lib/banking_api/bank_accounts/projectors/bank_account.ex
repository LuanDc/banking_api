defmodule BankingApi.BankAccounts.Projectors.BankAccount do
  use Commanded.Projections.Ecto,
    application: BankingApi.BankingApiApp,
    repo: BankingApi.Repo,
    name: "BankAccounts.Projectors.BankAccount",
    consistency: :strong

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  alias BankingApi.BankAccounts.Events.MoneyWithdrawn
  alias BankingApi.BankAccounts.Projections.BankAccount

  import BankingApi.BankAccounts.Queries,
    only: [
      bank_account_query: 1,
      increase_balance_query: 2,
      decrease_balance_query: 2
    ]

  project(
    %BankAccountOpened{id: id, account_number: account_number, initial_balance: balance},
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :bank_account, %BankAccount{
        id: id,
        account_number: account_number,
        balance: balance,
        status: :open
      })
    end
  )

  project(
    %MoneyDeposited{amount: amount, id: id},
    _metadata,
    fn multi ->
      update_bank_account(multi, increase_balance_query(id, amount))
    end
  )

  project(
    %MoneyWithdrawn{amount: amount, id: id},
    _metadata,
    fn multi ->
      update_bank_account(multi, decrease_balance_query(id, amount))
    end
  )

  project(
    %BankAccountClosed{id: id},
    _metadata,
    fn multi ->
      update_bank_account(multi, bank_account_query(id), status: :closed)
    end
  )

  defp update_bank_account(multi, query, changes \\ []) do
    Ecto.Multi.update_all(multi, :bank_account, query, set: changes)
  end
end
