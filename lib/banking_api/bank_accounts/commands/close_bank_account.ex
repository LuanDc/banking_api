defmodule BankingApi.BankAccounts.Commands.CloseBankAccount do
  defstruct [:id, :account_number]
  use Vex.Struct

  validates(:id, uuid: true)

  validates(:account_number,
    presence: [message: "can't be empty"],
    string: true
  )

  def new do
    %__MODULE__{}
  end

  def assign_id(%__MODULE__{} = close_bank_account, id) do
    %__MODULE__{close_bank_account | id: id}
  end

  def assign_account_number(%__MODULE__{} = close_bank_account, account_number) do
    %__MODULE__{close_bank_account | account_number: account_number}
  end
end
