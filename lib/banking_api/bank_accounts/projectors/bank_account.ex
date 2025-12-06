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
  alias BankingApi.BankAccounts.Projections.Transaction

  import BankingApi.BankAccounts.Queries,
    only: [
      bank_account_query: 1,
      update_bank_account: 3
    ]

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

  def project_bank_account_opened(multi, %BankAccountOpened{
        id: id,
        account_number: account_number,
        status: status,
        initial_balance: initial_balance,
        date: date
      }) do
    multi
    |> Ecto.Multi.insert(:bank_account, %BankAccount{
      id: id,
      account_number: account_number,
      status: String.to_existing_atom(status),
      balance: initial_balance
    })
    |> Ecto.Multi.insert(:transaction, %Transaction{
      id: Ecto.UUID.generate(),
      bank_account_id: id,
      account_number: account_number,
      type: "deposit",
      amount: initial_balance,
      date: parse_date(date)
    })
  end

  def project_money_deposited(multi, %MoneyDeposited{
        id: id,
        amount: amount,
        date: date
      }) do
    multi
    |> update_bank_account(bank_account_query(id),
      inc: [balance: amount]
    )
    |> Ecto.Multi.run(:transaction, fn repo, _changes ->
      bank_account = repo.get(BankAccount, id)

      transaction = %Transaction{
        id: Ecto.UUID.generate(),
        bank_account_id: id,
        account_number: bank_account.account_number,
        type: "deposit",
        amount: amount,
        date: parse_date(date)
      }

      repo.insert(transaction)
    end)
  end

  def project_money_withdrawn(multi, %MoneyWithdrawn{
        id: id,
        amount: amount,
        date: date
      }) do
    multi
    |> update_bank_account(bank_account_query(id),
      inc: [balance: -amount]
    )
    |> Ecto.Multi.run(:transaction, fn repo, _changes ->
      bank_account = repo.get(BankAccount, id)

      transaction = %Transaction{
        id: Ecto.UUID.generate(),
        bank_account_id: id,
        account_number: bank_account.account_number,
        type: "withdrawal",
        amount: amount,
        date: parse_date(date)
      }

      repo.insert(transaction)
    end)
  end

  def project_bank_account_closed(multi, %BankAccountClosed{
        account_number: account_number,
        status: status
      }) do
    update_bank_account(multi, bank_account_query(account_number: account_number), set: [status: status])
  end

  def project_bank_account_status_updated(multi, %BankAccountStatusUpdated{
        account_number: account_number,
        status: status
      }) do
    update_bank_account(multi, bank_account_query(account_number: account_number),
      set: [status: String.to_existing_atom(status)]
    )
  end

  defp parse_date(nil), do: DateTime.utc_now()
  defp parse_date(%DateTime{} = date), do: date

  defp parse_date(date) when is_binary(date) do
    case DateTime.from_iso8601(date) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> DateTime.utc_now()
    end
  end
end
