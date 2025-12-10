defmodule BankingApi.BankAccounts.Projectors.BankAccountOpeningRequest do
  use Commanded.Projections.Ecto,
    application: BankingApi.BankingApiApp,
    repo: BankingApi.Repo,
    name: "BankAccounts.Projectors.BankAccountOpeningRequest",
    consistency: :strong

  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested
  alias BankingApi.BankAccounts.Events.BankAccountOpeningFailed
  alias BankingApi.BankAccounts.Events.BankAccountOpeningCompleted
  alias BankingApi.BankAccounts.Projections.BankAccountOpeningRequest

  def project_bank_account_opening_requested(multi, %BankAccountOpeningRequested{
        id: id,
        request_id: request_id,
        account_number: account_number,
        initial_balance: initial_balance,
        status: status,
        request_status: request_status,
        date: date
      }) do
    Ecto.Multi.insert(multi, :bank_account_opening_request, %BankAccountOpeningRequest{
      id: id,
      request_id: request_id,
      account_number: account_number,
      initial_balance: initial_balance,
      status: parse_status(status),
      request_status: parse_request_status(request_status),
      requested_at: parse_date(date)
    })
  end

  defp parse_status(status) when is_binary(status), do: String.to_existing_atom(status)
  defp parse_status(status) when is_atom(status), do: status

  defp parse_request_status(request_status) when is_binary(request_status),
    do: String.to_existing_atom(request_status)

  defp parse_request_status(request_status) when is_atom(request_status), do: request_status

  defp parse_date(nil), do: DateTime.utc_now()
  defp parse_date(%DateTime{} = date), do: date

  defp parse_date(date) when is_binary(date) do
    case DateTime.from_iso8601(date) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> DateTime.utc_now()
    end
  end

  def project_bank_account_opening_failed(multi, %BankAccountOpeningFailed{
        id: id,
        error_reason: error_reason
      }) do
    Ecto.Multi.update_all(
      multi,
      :bank_account_opening_request_failed,
      from(r in BankAccountOpeningRequest, where: r.id == ^id),
      set: [
        request_status: :failed,
        error: error_reason
      ]
    )
  end

  def project_bank_account_opening_completed(multi, %BankAccountOpeningCompleted{
        bank_account_id: bank_account_id
      }) do
    Ecto.Multi.update_all(
      multi,
      :bank_account_opening_request_completed,
      from(r in BankAccountOpeningRequest, where: r.id == ^bank_account_id),
      set: [
        request_status: :completed
      ]
    )
  end

  # Commanded projections
  project(
    %BankAccountOpeningRequested{} = event,
    _metadata,
    fn multi -> project_bank_account_opening_requested(multi, event) end
  )

  project(
    %BankAccountOpeningFailed{} = event,
    _metadata,
    fn multi -> project_bank_account_opening_failed(multi, event) end
  )

  project(
    %BankAccountOpeningCompleted{} = event,
    _metadata,
    fn multi -> project_bank_account_opening_completed(multi, event) end
  )
end
