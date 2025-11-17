defmodule BankingApi.BankAccounts.Commands.OpenBankAccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  describe "new/1" do
    test "returns a OpenBankAccount command struct with the given initial values" do
      params = %{"initial_balance" => 1000}
      bank_account = OpenBankAccount.new(params)
      assert %OpenBankAccount{initial_balance: 1000} = bank_account
    end
  end

  describe "assign_id/2" do
    test "returns OpenBankAccount command struct with id assigned" do
      id = Ecto.UUID.generate()
      bank_account = OpenBankAccount.assign_id(%OpenBankAccount{}, id)
      assert bank_account.id == id
    end
  end

  describe "valid?/1" do
    @open_bank_account_command %OpenBankAccount{
      initial_balance: 1000,
      account_number: "1234567890",
      status: "open"
    }

    @required_params [:initial_balance, :account_number, :status]

    for required_param <- @required_params do
      test "returns an error with the reason when #{required_param} param is not given" do
        param = Map.new() |> Map.put_new(unquote(required_param), nil)
        open_bank_account_command = struct(@open_bank_account_command, param)
        refute OpenBankAccount.valid?(open_bank_account_command)
      end
    end

    test "returns an error when the given initial balance is not greater than 0" do
      open_bank_account_command = %OpenBankAccount{
        @open_bank_account_command
        | initial_balance: -1
      }

      refute OpenBankAccount.valid?(open_bank_account_command)
    end

    test "returns an error when the given is status is not open or closed" do
      open_bank_account_command = %OpenBankAccount{
        @open_bank_account_command
        | status: "invalid_status"
      }

      refute OpenBankAccount.valid?(open_bank_account_command)
    end
  end
end
