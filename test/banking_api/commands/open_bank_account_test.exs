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
end
