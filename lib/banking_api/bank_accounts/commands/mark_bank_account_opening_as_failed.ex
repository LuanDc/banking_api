defmodule BankingApi.BankAccounts.Commands.MarkBankAccountOpeningAsFailed do
  defstruct [
    :request_id,
    :error_reason
  ]

  def new(attrs) do
    %__MODULE__{
      request_id: Map.get(attrs, :request_id),
      error_reason: Map.get(attrs, :error_reason)
    }
  end
end
