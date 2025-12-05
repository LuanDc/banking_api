defmodule BankingApi.BankAccounts.Projectors.BankAccountTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.Repo

  describe "BankAccountOpened projection" do
    @tag :integration
    test "creates bank account in read model with initial balance" do
      account_number = "ACC-PROJ-001"
      initial_balance = 1000

      setup_bank_account(account_number, initial_balance)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.account_number == account_number
      assert bank_account.balance == initial_balance
      assert bank_account.status == :active
    end

    @tag :integration
    test "creates bank account with zero initial balance" do
      account_number = "ACC-PROJ-002"

      setup_bank_account(account_number, 0)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == 0
      assert bank_account.status == :active
    end
  end

  describe "MoneyDeposited projection" do
    @tag :integration
    test "increments balance when money is deposited" do
      account_number = "ACC-PROJ-003"
      initial_balance = 500
      deposit_amount = 300
      expected_balance = initial_balance + deposit_amount

      setup_bank_account_with_history(account_number, initial_balance, [
        {:deposit, deposit_amount}
      ])

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == expected_balance
    end

    @tag :integration
    test "handles multiple deposits correctly" do
      account_number = "ACC-PROJ-004"
      initial_balance = 1000
      first_deposit = 200
      second_deposit = 300
      expected_balance = initial_balance + first_deposit + second_deposit

      setup_bank_account_with_history(account_number, initial_balance, [
        {:deposit, first_deposit},
        {:deposit, second_deposit}
      ])

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == expected_balance
    end
  end

  describe "MoneyWithdrawn projection" do
    @tag :integration
    test "decrements balance when money is withdrawn" do
      account_number = "ACC-PROJ-005"
      initial_balance = 2000
      withdrawal_amount = 500
      expected_balance = initial_balance - withdrawal_amount

      setup_bank_account_with_history(account_number, initial_balance, [
        {:withdraw, withdrawal_amount}
      ])

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == expected_balance
    end

    @tag :integration
    test "handles multiple withdrawals correctly" do
      account_number = "ACC-PROJ-006"
      initial_balance = 2000
      first_withdrawal = 300
      second_withdrawal = 200
      expected_balance = initial_balance - first_withdrawal - second_withdrawal

      setup_bank_account_with_history(account_number, initial_balance, [
        {:withdraw, first_withdrawal},
        {:withdraw, second_withdrawal}
      ])

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == expected_balance
    end

    @tag :integration
    test "handles withdrawal to zero balance" do
      account_number = "ACC-PROJ-007"
      initial_balance = 500

      setup_bank_account_with_history(account_number, initial_balance, [
        {:withdraw, initial_balance}
      ])

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == 0
    end
  end

  describe "BankAccountClosed projection" do
    @tag :integration
    test "updates account status to inactive" do
      account_number = "ACC-PROJ-008"

      setup_closed_bank_account(account_number, 0)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.status == :inactive
    end

    @tag :integration
    test "keeps balance unchanged when closing account" do
      account_number = "ACC-PROJ-009"
      final_balance = 500

      setup_closed_bank_account(account_number, final_balance)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == final_balance
      assert bank_account.status == :inactive
    end
  end

  describe "Complex projection scenarios" do
    @tag :integration
    test "projects sequence of deposits and withdrawals correctly" do
      account_number = "ACC-PROJ-010"
      initial_balance = 1000

      setup_bank_account_with_history(account_number, initial_balance, [
        {:deposit, 500},
        {:withdraw, 200},
        {:deposit, 100},
        {:withdraw, 300}
      ])

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)

      assert bank_account.balance == 1100
      assert bank_account.status == :active
    end
  end
end
