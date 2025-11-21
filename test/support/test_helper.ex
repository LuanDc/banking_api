defmodule BankingApi.TestHelper do
  def validate_uuid_format(uuid) when is_bitstring(uuid) do
    case Ecto.UUID.cast(uuid) do
      {:ok, _uuid} -> true
      _ -> false
    end
  end
end
