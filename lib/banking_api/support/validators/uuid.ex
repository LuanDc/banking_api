defmodule BankingApi.Support.Validators.Uuid do
  use Vex.Validator

  def validate(value, _options) do
    Vex.Validators.By.validate(value,
      function: &valid_uuid?/1,
      allow_nil: false,
      allow_blank: false
    )
  end

  defp valid_uuid?(uuid) do
    case Ecto.UUID.cast(uuid) do
      {:ok, _} -> true
      :error -> false
    end
  end
end
