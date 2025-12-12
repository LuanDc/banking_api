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
  alias BankingApi.BankAccounts.Events.TransferCompleted
  alias BankingApi.BankAccounts.Events.TransferReceived
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankAccounts.Projections.Transaction

  import BankingApi.BankAccounts.Queries,
    only: [
      bank_account_query: 1,
      update_bank_account: 3
    ]

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
        bank_account_id: bank_account_id,
        amount: amount,
        date: date
      }) do
    multi
    |> update_bank_account(bank_account_query(bank_account_id),
      inc: [balance: amount]
    )
    |> Ecto.Multi.run(:transaction, fn repo, _changes ->
      bank_account = repo.get(BankAccount, bank_account_id)

      transaction = %Transaction{
        id: Ecto.UUID.generate(),
        bank_account_id: bank_account_id,
        account_number: bank_account.account_number,
        type: "deposit",
        amount: amount,
        date: parse_date(date)
      }

      repo.insert(transaction)
    end)
  end

  def project_money_withdrawn(multi, %MoneyWithdrawn{
        bank_account_id: bank_account_id,
        amount: amount,
        date: date
      }) do
    multi
    |> update_bank_account(bank_account_query(bank_account_id),
      inc: [balance: -amount]
    )
    |> Ecto.Multi.run(:transaction, fn repo, _changes ->
      bank_account = repo.get(BankAccount, bank_account_id)

      transaction = %Transaction{
        id: Ecto.UUID.generate(),
        bank_account_id: bank_account_id,
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
    update_bank_account(multi, bank_account_query(account_number: account_number),
      set: [status: status]
    )
  end

  def project_bank_account_status_updated(multi, %BankAccountStatusUpdated{
        bank_account_id: bank_account_id,
        status: status
      }) do
    update_bank_account(multi, bank_account_query(bank_account_id),
      set: [status: String.to_existing_atom(status)]
    )
  end

  def project_transfer_completed(multi, %TransferCompleted{
        id: transfer_id,
        from_account_id: from_account_id,
        amount: amount,
        date: date
      }) do
    multi
    |> update_bank_account(bank_account_query(from_account_id),
      inc: [balance: -amount]
    )
    |> Ecto.Multi.run(:transaction, fn repo, _changes ->
      bank_account = repo.get(BankAccount, from_account_id)

      transaction = %Transaction{
        id: transfer_id,
        bank_account_id: from_account_id,
        account_number: bank_account.account_number,
        type: "transfer_out",
        amount: amount,
        date: parse_date(date)
      }

      repo.insert(transaction)
    end)
  end

  def project_transfer_received(multi, %TransferReceived{
        id: transfer_id,
        to_account_id: to_account_id,
        amount: amount,
        date: date
      }) do
    multi
    |> update_bank_account(bank_account_query(to_account_id),
      inc: [balance: amount]
    )
    |> Ecto.Multi.run(:transaction, fn repo, _changes ->
      bank_account = repo.get(BankAccount, to_account_id)

      transaction = %Transaction{
        id: transfer_id,
        bank_account_id: to_account_id,
        account_number: bank_account.account_number,
        type: "transfer_in",
        amount: amount,
        date: parse_date(date)
      }

      repo.insert(transaction)
    end)
  end

  defp parse_date(nil), do: DateTime.utc_now()
  defp parse_date(%DateTime{} = date), do: date

  defp parse_date(date) when is_binary(date) do
    case DateTime.from_iso8601(date) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> DateTime.utc_now()
    end
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

  project(
    %TransferCompleted{} = event,
    _metadata,
    fn multi -> project_transfer_completed(multi, event) end
  )

  project(
    %TransferReceived{} = event,
    _metadata,
    fn multi -> project_transfer_received(multi, event) end
  )
end
