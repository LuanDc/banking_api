defmodule BankingApi.CommandsFactory do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.OpenBankAccount
  alias BankingApi.BankAccounts.Commands.CloseBankAccount
  alias BankingApi.BankAccounts.Commands.DepositMoney

  def dispatch(command, attrs \\ [])
      when is_struct(command) and is_list(attrs) do
    command = build_command(command, attrs)
    :ok = BankingApiApp.dispatch(command, consistency: :strong)
    command
  end

  def build_command(command, attrs \\ [])

  def build_command(%OpenBankAccount{}, attrs) do
    attrs = Enum.into(attrs, %{})

    struct(
      %OpenBankAccount{
        id: "1f430bb5-81fc-4de3-8c8f-e3fc00adf896",
        account_number: "ACC-123456",
        initial_balance: 0,
        status: "open"
      },
      attrs
    )
  end

  def build_command(%CloseBankAccount{}, attrs) do
    attrs = Enum.into(attrs, %{})
    struct(%CloseBankAccount{account_number: "ACC-123456"}, attrs)
  end

  def build_command(%DepositMoney{}, attrs) do
    attrs = Enum.into(attrs, %{})
    struct(%DepositMoney{account_number: "ACC-123456", amount: 50}, attrs)
  end
end
