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
      decrease_balance_query: 2,
      update_bank_account: 2,
      update_bank_account: 3
    ]

  project(
    %BankAccountOpened{
      id: id,
      account_number: account_number,
      balance: balance,
      status: status
    },
    _metadata,
    fn multi ->
      Ecto.Multi.insert(multi, :bank_account, %BankAccount{
        id: id,
        account_number: account_number,
        status: String.to_existing_atom(status),
        balance: balance
      })
    end
  )

  project(
    %MoneyDeposited{account_number: account_number, balance: balance},
    _metadata,
    fn multi ->
      update_bank_account(multi, bank_account_query(account_number: account_number),
        balance: balance
      )
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
end
