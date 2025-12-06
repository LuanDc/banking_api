defmodule BankingApi.BankAccounts.Commands.CloseBankAccountTest do
  use ExUnit.Case, async: true

  import BankingApi.CommandValidator, only: [validate: 1]

  alias BankingApi.BankAccounts.Commands.CloseBankAccount

  @tag :unit
  test "success: passes valid command through the pipeline" do
    attrs = %{"id" => Ecto.UUID.generate()}

    command = CloseBankAccount.new(attrs)

    result = validate(command)

    refute result.halted
    assert result.response == nil
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with missing fields" do
    empty_attrs = %{}
    command = CloseBankAccount.new(empty_attrs)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors == %{id: ["can't be empty", "must be valid"]}
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with invalid id type" do
    invalid_params = %{"id" => 1}
    command = CloseBankAccount.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:id] == ["must be valid"]
  end
end
