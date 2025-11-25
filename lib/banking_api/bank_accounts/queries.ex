defmodule BankingApi.BankAccounts.Queries do
  import Ecto.Query, only: [from: 2]

  alias BankingApi.BankAccounts.Projections.BankAccount

  def bank_account_query(account_number: account_number) do
    from(ba in BankAccount, where: ba.account_number == ^account_number)
  end

  def bank_account_query(bank_account_uuid) when is_bitstring(bank_account_uuid) do
    from(ba in BankAccount, where: ba.id == ^bank_account_uuid)
  end

  def decrease_balance_query(id, amount) do
    from(ba in BankAccount,
      where: ba.id == ^id,
      update: [inc: [balance: ^(-amount)]]
    )
  end

  def update_bank_account(multi, query, changes \\ []) do
    Ecto.Multi.update_all(multi, :bank_account, query, changes)
  end
end
