defmodule BankingApi.BankAccounts.Commands.OpenBankAccountTest do
  use ExUnit.Case, async: true

  import BankingApi.CommandValidator, only: [validate: 1]

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  @tag :unit
  test "success: passes valid command through the pipeline" do
    attrs = %{
      "id" => Ecto.UUID.generate(),
      "account_number" => "ACC-1",
      "initial_balance" => 100,
      "status" => "active",
      "request_id" => Ecto.UUID.generate()
    }

    command = OpenBankAccount.new(attrs)

    result = validate(command)

    refute result.halted
    assert result.response == nil
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with missing fields" do
    empty_attrs = %{}
    command = OpenBankAccount.new(empty_attrs)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response

    assert errors == %{
             id: ["must be valid"],
             status: ["must be one of [\"active\", \"inactive\"]"],
             account_number: ["can't be empty"],
             initial_balance: ["must be a number greater than or equal to 0"],
             request_id: ["must be valid"]
           }
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with invalid id type" do
    invalid_params = %{
      "id" => 1,
      "account_number" => "ACC-1",
      "initial_balance" => 100,
      "status" => "active"
    }

    command = OpenBankAccount.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:id] == ["must be valid"]
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with invalid account number type" do
    invalid_params = %{
      "id" => Ecto.UUID.generate(),
      "account_number" => 1,
      "initial_balance" => 100,
      "status" => "active"
    }

    command = OpenBankAccount.new(invalid_params)

    result = validate(command)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:account_number] == ["is not a valid string"]
  end
end
