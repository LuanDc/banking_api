defmodule BankingApi.BankAccounts.Commands.CloseBankAccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.Support.Middleware.Validate
  alias Commanded.Middleware.Pipeline
  alias BankingApi.BankAccounts.Commands.CloseBankAccount

  @tag :unit
  test "success: passes valid command through the pipeline" do
    attrs = %{"account_number" => "ACC-1"}

    command = CloseBankAccount.new(attrs)

    pipeline = %Pipeline{command: command}
    result = Validate.before_dispatch(pipeline)

    refute result.halted
    assert result.response == nil
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with missing fields" do
    empty_attrs = %{}
    command = CloseBankAccount.new(empty_attrs)
    pipeline = %Pipeline{command: command}

    result = Validate.before_dispatch(pipeline)

    assert {:error, :validation_failure, errors} = result.response
    assert errors == %{account_number: ["can't be empty"]}
  end

  @tag :unit
  test "error: halts pipeline and returns validation errors for command with invalid account number type" do
    invalid_params = %{"account_number" => 1}
    command = CloseBankAccount.new(invalid_params)
    pipeline = %Pipeline{command: command}

    result = Validate.before_dispatch(pipeline)

    assert {:error, :validation_failure, errors} = result.response
    assert errors[:account_number] == ["is not a valid string"]
  end
end
