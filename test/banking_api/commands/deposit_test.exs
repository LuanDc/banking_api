defmodule BankingApi.BankAccounts.Commands.DepositMoneyTest do
  use ExUnit.Case, async: true

  import BankingApi.CommandValidator, only: [validate: 1]

  alias BankingApi.BankAccounts.Commands.DepositMoney

  @tag :unit
  test "success: passes valid command through the pipeline" do
    attrs = %{"id" => Ecto.UUID.generate(), "amount" => 50}

    command = DepositMoney.new(attrs)

    result = validate(command)

    refute result.halted
    assert result.response == nil
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with missing fields" do
    empty_attrs = %{}
    command = DepositMoney.new(empty_attrs)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response

    assert errors == %{
             id: ["must be valid"],
             amount: ["must be a number greater than or equal to 0"]
           }
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with invalid id type" do
    invalid_params = %{"id" => 1, "amount" => 50}
    command = DepositMoney.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:id] == ["must be valid"]
  end
end
