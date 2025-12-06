defmodule BankingApi.BankAccounts.Projectors.BankAccount do
  use Commanded.Projections.Ecto,
    application: BankingApi.BankingApiApp,
    repo: BankingApi.Repo,
    name: "BankAccounts.Projectors.BankAccount",
    consistency: :strong

  alias BankingApi.BankAccounts.Events.BankAccountOpened
  alias BankingApi.BankAccounts.Events.BankAccountClosed
  alias BankingApi.BankAccounts.Events.BankAccountStatusUpdated
  alias BankingApi.BankAccounts.Events.MoneyDeposited
  alias BankingApi.BankAccounts.Events.MoneyWithdrawn
  alias BankingApi.BankAccounts.Projections.BankAccount

  import BankingApi.BankAccounts.Queries,
    only: [
      bank_account_query: 1,
      update_bank_account: 3
    ]

  # Public functions for testing
  def project_bank_account_opened(multi, %BankAccountOpened{
        id: id,
        account_number: account_number,
        status: status,
        initial_balance: initial_balance
      }) do
    Ecto.Multi.insert(multi, :bank_account, %BankAccount{
      id: id,
      account_number: account_number,
      status: String.to_existing_atom(status),
      balance: initial_balance
    })
  end

  def project_money_deposited(multi, %MoneyDeposited{account_number: account_number, amount: amount}) do
    update_bank_account(multi, bank_account_query(account_number: account_number),
      inc: [balance: amount]
    )
  end

  def project_money_withdrawn(multi, %MoneyWithdrawn{account_number: account_number, amount: amount}) do
    update_bank_account(multi, bank_account_query(account_number: account_number),
      inc: [balance: -amount]
    )
  end

  def project_bank_account_closed(multi, %BankAccountClosed{account_number: account_number, status: status}) do
    update_bank_account(multi, bank_account_query(account_number: account_number),
      set: [status: status]
    )
  end

  def project_bank_account_status_updated(multi, %BankAccountStatusUpdated{
        account_number: account_number,
        status: status
      }) do
    update_bank_account(multi, bank_account_query(account_number: account_number),
      set: [status: String.to_existing_atom(status)]
    )
  end

  # Commanded projections
  project(
    %BankAccountOpened{} = event,
    _metadata,
    fn multi -> project_bank_account_opened(multi, event) end
  )

  project(
    %MoneyDeposited{} = event,
    _metadata,
    fn multi -> project_money_deposited(multi, event) end
  )

  project(
    %MoneyWithdrawn{} = event,
    _metadata,
    fn multi -> project_money_withdrawn(multi, event) end
  )

  project(
    %BankAccountClosed{} = event,
    _metadata,
    fn multi -> project_bank_account_closed(multi, event) end
  )

  project(
    %BankAccountStatusUpdated{} = event,
    _metadata,
    fn multi -> project_bank_account_status_updated(multi, event) end
  )
end
