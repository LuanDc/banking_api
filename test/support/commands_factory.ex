defmodule BankingApi.CommandsFactory do
  alias BankingApi.BankingApiApp
  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  def dispatch(command, attrs)
      when is_atom(command) and is_list(attrs) do
    :ok =
      command
      |> build(attrs)
      |> BankingApiApp.dispatch()
  end

  def build(:open_bank_account, attrs \\ []) do
    attrs = Enum.into(attrs, %{})

    struct(
      %OpenBankAccount{
        id: Ecto.UUID.generate(),
        account_number: "Jane Smith",
        initial_balance: 0
      },
      attrs
    )
  end
end
