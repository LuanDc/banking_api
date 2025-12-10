defmodule BankingApi.BankAccounts do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.RequestBankAccountOpening
  alias BankingApi.BankAccounts.Commands.DepositMoney
  alias BankingApi.BankAccounts.Commands.WithdrawMoney
  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus
  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankAccounts.Projections.Transaction
  alias BankingApi.Repo
  import Ecto.Query

  # Reader functions

  def get(id) when is_bitstring(id) do
    case Repo.get(BankAccount, id) do
      nil -> {:error, :not_found}
      bank_account -> {:ok, bank_account}
    end
  end

  def check_account_number_uniqueness(account_number) when is_bitstring(account_number) do
    case Repo.get_by(BankAccount, account_number: account_number) do
      nil -> :ok
      _bank_account -> {:error, :duplicated_account_number}
    end
  end

  def check_account_number_uniqueness(_), do: :ok

  def get_by!(filters) when is_list(filters) do
    Repo.get_by!(BankAccount, filters)
  end

  def list_transactions(bank_account_id, opts \\ []) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 20)

    page_size = min(page_size, 100)
    page = max(page, 1)

    offset = (page - 1) * page_size

    query =
      from t in Transaction,
        where: t.bank_account_id == ^bank_account_id,
        order_by: [desc: t.date]

    query =
      if start_date do
        from t in query, where: t.date >= ^start_date
      else
        query
      end

    query =
      if end_date do
        from t in query, where: t.date <= ^end_date
      else
        query
      end

    query =
      from t in query,
        limit: ^page_size,
        offset: ^offset

    Repo.all(query)
  end

  # Writer functions

  def open_bank_account(params) do
    id = Ecto.UUID.generate()

    command =
      params
      |> RequestBankAccountOpening.new()
      |> RequestBankAccountOpening.assign_id(id)

    BankingApiApp.dispatch(command, consistency: :strong)
  end

  def deposit(params) do
    command = DepositMoney.new(params)

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(command.bank_account_id)
    end
  end

  def withdraw(params) do
    command = WithdrawMoney.new(params)

    with :ok <- BankingApiApp.dispatch(command, consistency: :strong) do
      get(command.bank_account_id)
    end
  end

  def update_bank_account_status(params) do
    command = UpdateBankAccountStatus.new(params)

    with :ok <-
           BankingApiApp.dispatch(command, consistency: :strong) do
      get(command.bank_account_id)
    end
  end
end
