defmodule BankingApi.CommandsFactory do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  def dispatch(command, attrs)
      when is_atom(command) and is_list(attrs) do
    :ok =
      command
      |> build_command(attrs)
      |> BankingApiApp.dispatch()
  end

  def build_command(:open_bank_account, attrs \\ []) do
    attrs = Enum.into(attrs, %{})

    struct(
      %OpenBankAccount{
        id: Ecto.UUID.generate(),
        account_number: "ACC-123456",
        initial_balance: 0,
        status: "open"
      },
      attrs
    )
  end
end
