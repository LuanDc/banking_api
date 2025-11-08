defmodule BankingApi.BankAccounts.Projectors.BankAccount do
  use Commanded.Projections.Ecto,
    application: BankingApi.BankingApiApp,
    repo: BankingApi.Repo,
    name: "BankAccounts.Projectors.BankAccount",
    consistency: :strong

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Projections.BankAccount

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
    %BankAccountClosed{id: id},
    _metadata,
    fn multi ->
      update_bank_account(multi, id, status: :closed)
    end
  )

  defp update_bank_account(multi, bank_account_uuid, changes) do
    Ecto.Multi.update_all(multi, :bank_accounts, bank_account_query(bank_account_uuid),
      set: changes
    )
  end

  defp bank_account_query(bank_account_uuid) do
    from(ba in BankAccount, where: ba.id == ^bank_account_uuid)
  end
end
