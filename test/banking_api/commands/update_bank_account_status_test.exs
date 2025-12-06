defmodule BankingApi.BankAccounts.Commands.UpdateBankAccountStatusTest do
  use ExUnit.Case, async: true

  import BankingApi.CommandValidator, only: [validate: 1]

  alias BankingApi.BankAccounts.Commands.UpdateBankAccountStatus

  @tag :unit
  test "success: passes valid command through the pipeline" do
    attrs = %{
      "id" => Ecto.UUID.generate(),
      "status" => "inactive"
    }

    command = UpdateBankAccountStatus.new(attrs)
    result = validate(command)

    refute result.halted
    assert result.response == nil
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with missing fields" do
    empty_attrs = %{}
    command = UpdateBankAccountStatus.new(empty_attrs)

    result = validate(command)

    assert result.halted
    assert {:error, :validation_failure, errors} = result.response

    assert errors == %{
             status: ["must be one of [\"active\", \"inactive\"]"],
             id: ["can't be empty", "must be valid"]
           }
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for invalid status" do
    invalid_params = %{"id" => Ecto.UUID.generate(), "status" => "invalid"}
    command = UpdateBankAccountStatus.new(invalid_params)

    result = validate(command)

    assert result.halted
    assert {:error, :validation_failure, errors} = result.response
    assert errors[:status] == ["must be one of [\"active\", \"inactive\"]"]
  end
end
