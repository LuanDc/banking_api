defmodule BankingApi.BankAccounts.Projectors.BankAccountTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Projections.BankAccount
  alias BankingApi.BankingApiApp

  alias BankingApi.BankAccounts.Commands.{
    OpenBankAccount,
    DepositMoney,
    WithdrawMoney,
    CloseBankAccount
  }

  alias BankingApi.BankAccounts.Events.{
    BankAccountOpened,
    MoneyDeposited,
    MoneyWithdrawn,
    BankAccountClosed
  }

  alias BankingApi.Repo

  describe "project BankAccountOpened event" do
    @tag :unit
    test "success: creates a new bank account projection in the read database" do
      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: 1000)

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened)

      bank_account = Repo.get_by!(BankAccount, account_number: open_bank_account.account_number)

      assert bank_account.id == open_bank_account.id
      assert bank_account.account_number == open_bank_account.account_number
      assert bank_account.status == :open
      assert bank_account.balance == 1000
    end

    @tag :unit
    test "success: creates bank account with zero initial balance" do
      open_bank_account = build_command(%OpenBankAccount{})

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened)

      bank_account = Repo.get_by!(BankAccount, account_number: open_bank_account.account_number)

      assert bank_account.balance == 0
      assert bank_account.status == :open
    end

    @tag :unit
    test "success: verifies the projection uses BankAccount schema" do
      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: 500)

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened)

      bank_account = Repo.get_by!(BankAccount, account_number: open_bank_account.account_number)

      assert bank_account.__struct__ == BankAccount
    end

    @tag :unit
    test "success: converts status from string to atom in projection" do
      open_bank_account = build_command(%OpenBankAccount{})

      assert BankingApiApp.dispatch(open_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountOpened, fn event ->
        assert event.status == "open"
      end)

      bank_account = Repo.get_by!(BankAccount, account_number: open_bank_account.account_number)

      assert bank_account.status == :open
    end
  end

  describe "project MoneyDeposited event" do
    setup do
      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: 1000)
      assert BankingApiApp.dispatch(open_bank_account) == :ok
      wait_for_event(BankingApiApp, BankAccountOpened)

      %{account_number: open_bank_account.account_number}
    end

    @tag :unit
    test "success: increments the balance in the read database", %{account_number: account_number} do
      deposit_money = build_command(%DepositMoney{}, account_number: account_number, amount: 500)

      assert BankingApiApp.dispatch(deposit_money) == :ok

      wait_for_event(BankingApiApp, MoneyDeposited)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == 1500
    end

    @tag :unit
    test "success: handles multiple deposits correctly", %{account_number: account_number} do
      deposit1 = build_command(%DepositMoney{}, account_number: account_number, amount: 200)
      deposit2 = build_command(%DepositMoney{}, account_number: account_number, amount: 300)

      assert BankingApiApp.dispatch([deposit1, deposit2]) == :ok

      wait_for_event(BankingApiApp, MoneyDeposited, fn event ->
        assert event.amount in [200, 300]
      end)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == 1500
    end

    @tag :unit
    test "success: verifies the balance increment uses account_number query", %{
      account_number: account_number
    } do
      initial_bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      initial_balance = initial_bank_account.balance

      deposit_money = build_command(%DepositMoney{}, account_number: account_number, amount: 100)

      assert BankingApiApp.dispatch(deposit_money) == :ok

      wait_for_event(BankingApiApp, MoneyDeposited)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == initial_balance + 100
    end
  end

  describe "project MoneyWithdrawn event" do
    setup do
      open_bank_account = build_command(%OpenBankAccount{}, initial_balance: 2000)
      assert BankingApiApp.dispatch(open_bank_account) == :ok
      wait_for_event(BankingApiApp, BankAccountOpened)

      %{account_number: open_bank_account.account_number}
    end

    @tag :unit
    test "success: decrements the balance in the read database", %{account_number: account_number} do
      withdraw_money =
        build_command(%WithdrawMoney{}, account_number: account_number, amount: 500)

      assert BankingApiApp.dispatch(withdraw_money) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == 1500
    end

    @tag :unit
    test "success: handles multiple withdrawals correctly", %{account_number: account_number} do
      withdraw1 = build_command(%WithdrawMoney{}, account_number: account_number, amount: 300)
      withdraw2 = build_command(%WithdrawMoney{}, account_number: account_number, amount: 200)

      assert BankingApiApp.dispatch([withdraw1, withdraw2]) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn, fn event ->
        assert event.amount in [300, 200]
      end)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == 1500
    end

    @tag :unit
    test "success: handles withdrawal to zero balance", %{account_number: account_number} do
      withdraw_money =
        build_command(%WithdrawMoney{}, account_number: account_number, amount: 2000)

      assert BankingApiApp.dispatch(withdraw_money) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == 0
    end

    @tag :unit
    test "success: verifies the balance decrement uses negative increment", %{
      account_number: account_number
    } do
      initial_bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      initial_balance = initial_bank_account.balance

      withdraw_money =
        build_command(%WithdrawMoney{}, account_number: account_number, amount: 100)

      assert BankingApiApp.dispatch(withdraw_money) == :ok

      wait_for_event(BankingApiApp, MoneyWithdrawn)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.balance == initial_balance - 100
    end
  end

  describe "project BankAccountClosed event" do
    setup do
      open_bank_account = build_command(%OpenBankAccount{})
      assert BankingApiApp.dispatch(open_bank_account) == :ok
      wait_for_event(BankingApiApp, BankAccountOpened)

      %{account_number: open_bank_account.account_number}
    end

    @tag :unit
    test "success: updates the account status to closed in the read database", %{
      account_number: account_number
    } do
      close_bank_account =
        build_command(%CloseBankAccount{}, account_number: account_number)

      assert BankingApiApp.dispatch(close_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountClosed)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.status == :closed
    end

    @tag :unit
    test "success: keeps the balance unchanged when closing account", %{
      account_number: account_number
    } do
      bank_account_before = Repo.get_by!(BankAccount, account_number: account_number)
      initial_balance = bank_account_before.balance

      close_bank_account =
        build_command(%CloseBankAccount{}, account_number: account_number)

      assert BankingApiApp.dispatch(close_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountClosed)

      bank_account_after = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account_after.balance == initial_balance
    end

    @tag :unit
    test "success: status is converted from string to atom by Ecto.Enum", %{
      account_number: account_number
    } do
      close_bank_account =
        build_command(%CloseBankAccount{}, account_number: account_number)

      assert BankingApiApp.dispatch(close_bank_account) == :ok

      wait_for_event(BankingApiApp, BankAccountClosed, fn event ->
        assert event.status == "closed"
      end)

      bank_account = Repo.get_by!(BankAccount, account_number: account_number)
      assert bank_account.status == :closed
      assert is_atom(bank_account.status)
    end
  end
end
