defmodule BankingApi.Repo.Migrations.ChangeBankAccountStatusValues do
  use Ecto.Migration

  def up do
    # Update existing data: 'open' -> 'active', 'closed' -> 'inactive'
    execute "UPDATE bank_accounts SET status = 'active' WHERE status = 'open'"
    execute "UPDATE bank_accounts SET status = 'inactive' WHERE status = 'closed'"
  end

  def down do
    # Update existing data back: 'active' -> 'open', 'inactive' -> 'closed'
    execute "UPDATE bank_accounts SET status = 'open' WHERE status = 'active'"
    execute "UPDATE bank_accounts SET status = 'closed' WHERE status = 'inactive'"
  end
end
