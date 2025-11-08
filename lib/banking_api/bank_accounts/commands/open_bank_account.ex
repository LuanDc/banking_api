defmodule BankingApi.BankAccounts.Commands.OpenBankAccount do
  defstruct [:id, :account_number, :initial_balance]
  use Vex.Struct

  validates(:id, uuid: true)

  validates(:account_number,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:initial_balance,
    presence: [message: "can't be empty"],
    number: [greater_than_or_equal_to: 0]
  )

  def new do
    %__MODULE__{}
  end

  def assign_id(%__MODULE__{} = open_bank_account, id) do
    %__MODULE__{open_bank_account | id: id}
  end

  def assign_account_number(%__MODULE__{} = open_bank_account, account_number) do
    %__MODULE__{open_bank_account | account_number: account_number}
  end

  def assign_initial_balance(%__MODULE__{} = open_bank_account, initial_balance) do
    %__MODULE__{open_bank_account | initial_balance: initial_balance}
  end
end
