defmodule BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed do
  defstruct [
    :id,
    :error_reason
  ]

  def new(attrs) do
    %__MODULE__{
      id: Map.get(attrs, :id),
      error_reason: Map.get(attrs, :error_reason)
    }
  end
end
