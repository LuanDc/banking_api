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
      id: Ecto.UUID.generate(),
      initial_balance: 1000,
      account_number: "1234567890",
      status: "open"
    }

    @required_params [:id, :initial_balance, :account_number, :status]

    for required_param <- @required_params do
      test "returns false when #{required_param} param is not given" do
        param = Map.new() |> Map.put_new(unquote(required_param), nil)
        open_bank_account_command = struct(@open_bank_account_command, param)
        refute OpenBankAccount.valid?(open_bank_account_command)
      end
    end

    test "returns false when the given account number is not a string" do
      open_bank_account_command = %OpenBankAccount{
        @open_bank_account_command
        | account_number: 123_456
      }

      refute OpenBankAccount.valid?(open_bank_account_command)
    end

    test "returns false when the given initial balance is not greater than 0" do
      open_bank_account_command = %OpenBankAccount{
        @open_bank_account_command
        | initial_balance: -1
      }

      refute OpenBankAccount.valid?(open_bank_account_command)
    end

    test "returns true when the given is status is open or closed" do
      for status <- ["open", "closed"] do
        assert OpenBankAccount.valid?(%OpenBankAccount{
                 @open_bank_account_command
                 | status: status
               })
      end
    end

    test "returns false when the given is status is not open or closed" do
      refute OpenBankAccount.valid?(%OpenBankAccount{
               @open_bank_account_command
               | status: "invalid_status"
             })
    end
  end
end
