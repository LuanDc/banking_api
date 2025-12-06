defmodule BankingApi.BankAccounts.Commands.WithdrawMoneyTest do
  use ExUnit.Case, async: true

  import BankingApi.CommandValidator, only: [validate: 1]

  alias BankingApi.BankAccounts.Commands.WithdrawMoney

  @tag :unit
  test "success: passes valid command through the pipeline" do
    attrs = %{"id" => Ecto.UUID.generate(), "amount" => 50}

    command = WithdrawMoney.new(attrs)

    result = validate(command)

    refute result.halted
    assert result.response == nil
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with missing fields" do
    empty_attrs = %{}
    command = WithdrawMoney.new(empty_attrs)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response

    assert errors == %{
             id: ["can't be empty", "must be valid"],
             amount: ["can't be empty", "must be a number greater than or equal to 0"]
           }
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with invalid id type" do
    invalid_params = %{"id" => 1, "amount" => 50}
    command = WithdrawMoney.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:id] == ["must be valid"]
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for negative amount" do
    invalid_params = %{"id" => Ecto.UUID.generate(), "amount" => -10}
    command = WithdrawMoney.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:amount] == ["must be a number greater than or equal to 0"]
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for invalid UUID" do
    invalid_params = %{"id" => "invalid-uuid", "amount" => 50}
    command = WithdrawMoney.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:id] == ["must be valid"]
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for nil id" do
    invalid_params = %{"id" => nil, "amount" => 50}
    command = WithdrawMoney.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:id] == ["can't be empty", "must be valid"]
  end
end
