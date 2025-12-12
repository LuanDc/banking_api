defmodule BankingApi.BankAccounts.Commands.InitiateTransfer do
  defstruct [:request_id, :id, :from_account_id, :to_account_id, :amount]
  use ExConstructor
  use Vex.Struct

  validates(:request_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:id, uuid: true)

  validates(:from_account_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:to_account_id,
    presence: [message: "can't be empty"],
    uuid: true
  )

  validates(:amount,
    presence: [message: "can't be empty"],
    number: [greater_than: 0]
  )

  def assign_id(%__MODULE__{} = command, id) do
    %__MODULE__{command | id: id}
  end
end
