defmodule BankingApi.BankAccounts.Commands.OpenBankAccountTest do
  use ExUnit.Case, async: true

  alias BankingApi.BankAccounts.Commands.OpenBankAccount

  import BankingApi.CommandsFactory

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
    @required_params [:id, :initial_balance, :account_number, :status]

    for required_param <- @required_params do
      test "returns false when #{required_param} param is not given" do
        empty_param = Map.new() |> Map.put_new(unquote(required_param), nil)
        command = build_command(:open_bank_account, empty_param)
        refute OpenBankAccount.valid?(command)
      end
    end

    test "returns false when the given id is not UUID" do
      command = build_command(:open_bank_account, id: "1")
      refute OpenBankAccount.valid?(command)
    end

    test "returns false when the given account number is not a string" do
      command = build_command(:open_bank_account, account_number: 123_456)
      refute OpenBankAccount.valid?(command)
    end

    test "returns false when the given initial balance is not greater than 0" do
      command = build_command(:open_bank_account, initial_balance: -1)
      refute OpenBankAccount.valid?(command)
    end

    test "returns true when the given is status is open or closed" do
      for status <- ["open", "closed"] do
        command = build_command(:open_bank_account, status: status)
        assert OpenBankAccount.valid?(command)
      end
    end

    test "returns false when the given is status is not open or closed" do
      command = build_command(:open_bank_account, status: "invalid_status")
      refute OpenBankAccount.valid?(command)
    end
  end
end
