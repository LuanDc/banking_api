defmodule BankingApi.Support.Validators.String do
  use Vex.Validator

  def validate(nil, _options), do: :ok
  def validate("", _options), do: :ok

  def validate(value, _options) when is_binary(value) do
    Vex.Validators.By.validate(value, function: &String.valid?/1)
  end

  def validate(_value, _options) do
    {:error, "is not a valid string"}
  end
end
