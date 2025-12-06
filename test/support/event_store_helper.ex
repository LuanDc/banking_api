defmodule BankingApi.EventStoreHelper do
  @moduledoc """
  Helper module for inserting events directly into the Event Store for testing purposes.

  This approach decouples tests from command handlers and aggregates, making tests:
  - Faster (no command processing overhead)
  - More isolated (failures in commands don't affect tests)
  - More focused (test only the layer you care about)

  ## Usage

      # In your test
      alias BankingApi.EventStoreHelper

      test "withdraws money successfully", %{conn: conn} do
        # Arrange: Insert events directly
        EventStoreHelper.append_events("account-123", [
          bank_account_opened(account_number: "account-123", initial_balance: 200)
        ])

        # Act: Test your controller/service
        conn = post(conn, ~p"/api/bank_account/withdraw", %{
          "account_number" => "account-123",
          "amount" => 50
        })

        # Assert
        assert response(conn, 201)
      end
  """

  alias BankingApi.BankAccounts.Events.{
    BankAccountOpened,
    MoneyDeposited,
    MoneyWithdrawn,
    BankAccountClosed
  }

  @doc """
  Appends events directly to the Event Store for a given stream.

  ## Parameters

    * `stream_id` - The stream identifier (e.g., "bank-account-123")
    * `events` - A list of event structs to append
    * `opts` - Optional keyword list with:
      * `:expected_version` - Expected version of the stream (default: `:any_version`)
      * `:metadata` - Map of metadata to attach to events (default: `%{}`)

  ## Examples

      # Append single event
      append_events("bank-account-123", [
        %BankAccountOpened{
          id: "uuid-123",
          account_number: "123",
          initial_balance: 1000,
          status: "active"
        }
      ])

      # Append multiple events with expected version
      append_events("bank-account-123", [
        %MoneyDeposited{account_number: "123", amount: 500},
        %MoneyWithdrawn{account_number: "123", amount: 200}
      ], expected_version: 1)
  """
  def append_events(stream_id, events, opts \\ []) when is_list(events) do
    expected_version = Keyword.get(opts, :expected_version, :any_version)
    metadata = Keyword.get(opts, :metadata, %{})

    event_data =
      events
      |> Enum.map(&to_event_data(&1, metadata))

    case BankingApi.EventStore.append_to_stream(stream_id, expected_version, event_data) do
      :ok -> :ok
      {:ok, _} -> :ok
      {:error, reason} -> raise "Failed to append events: #{inspect(reason)}"
    end
  end

  @doc """
  Helper to create a BankAccountOpened event with defaults.

  ## Options

    * `:id` - Account ID (default: generated UUID)
    * `:account_number` - Account number (required)
    * `:initial_balance` - Initial balance (default: 0)
    * `:status` - Account status (default: "active")

  ## Examples

      bank_account_opened(account_number: "123", initial_balance: 1000)
  """
  def bank_account_opened(opts \\ []) do
    %BankAccountOpened{
      id: Keyword.get(opts, :id, Ecto.UUID.generate()),
      account_number: Keyword.get(opts, :account_number, "0001-01"),
      initial_balance: Keyword.get(opts, :initial_balance, 0),
      status: Keyword.get(opts, :status, "active")
    }
  end

  @doc """
  Helper to create a MoneyDeposited event.

  ## Options

    * `:account_number` - Account number (required)
    * `:amount` - Amount to deposit (required)

  ## Examples

      money_deposited(account_number: "123", amount: 500)
  """
  def money_deposited(opts) do
    %MoneyDeposited{
      account_number: Keyword.fetch!(opts, :account_number),
      amount: Keyword.fetch!(opts, :amount)
    }
  end

  @doc """
  Helper to create a MoneyWithdrawn event.

  ## Options

    * `:account_number` - Account number (required)
    * `:amount` - Amount to withdraw (required)

  ## Examples

      money_withdrawn(account_number: "123", amount: 200)
  """
  def money_withdrawn(opts) do
    %MoneyWithdrawn{
      account_number: Keyword.fetch!(opts, :account_number),
      amount: Keyword.fetch!(opts, :amount)
    }
  end

  @doc """
  Helper to create a BankAccountClosed event.

  ## Options

    * `:account_number` - Account number (required)
    * `:status` - Account status (default: "inactive")

  ## Examples

      bank_account_closed(account_number: "123")
  """
  def bank_account_closed(opts) do
    %BankAccountClosed{
      account_number: Keyword.fetch!(opts, :account_number),
      status: Keyword.get(opts, :status, "inactive")
    }
  end

  def setup_bank_account() do
    event = bank_account_opened()

    stream_id = "bank-account-#{event.id}"

    events = [event]

    append_events(stream_id, events)

    # Give time for projections to process
    Process.sleep(50)

    BankingApi.Repo.get!(BankingApi.BankAccounts.Projections.BankAccount, event.id)
  end

  @doc """
  Convenience function to setup a bank account with initial balance.

  This is the most common test scenario: an open account with some balance.

  ## Parameters

    * `account_number` - The account number
    * `balance` - The initial balance (default: 0)

  ## Examples

      # Create account with 1000 balance
      setup_bank_account("account-123", 1000)

      # Create account with 0 balance
      setup_bank_account("account-123")
  """
  def setup_bank_account(account_number, balance \\ 0) do
    event =
      bank_account_opened(
        account_number: account_number,
        initial_balance: balance
      )

    stream_id = "bank-account-#{event.id}"

    append_events(stream_id, [event])

    # Give time for projections to process
    Process.sleep(50)

    BankingApi.Repo.get!(BankingApi.BankAccounts.Projections.BankAccount, event.id)
  end

  @doc """
  Convenience function to setup a bank account with a history of transactions.

  ## Parameters

    * `account_number` - The account number
    * `initial_balance` - The initial balance
    * `transactions` - List of `{:deposit, amount}` or `{:withdraw, amount}` tuples

  ## Examples

      # Account with deposits and withdrawals
      setup_bank_account_with_history("account-123", 1000, [
        {:deposit, 500},
        {:withdraw, 200},
        {:deposit, 100}
      ])
  """
  def setup_bank_account_with_history(account_number, initial_balance, transactions) do
    opened_event =
      bank_account_opened(
        account_number: account_number,
        initial_balance: initial_balance
      )

    stream_id = "bank-account-#{opened_event.id}"

    transaction_events =
      Enum.map(transactions, fn
        {:deposit, amount} -> money_deposited(account_number: account_number, amount: amount)
        {:withdraw, amount} -> money_withdrawn(account_number: account_number, amount: amount)
      end)

    all_events = [opened_event | transaction_events]

    append_events(stream_id, all_events)

    # Give time for projections to process
    Process.sleep(50)

    account_number
  end

  @doc """
  Convenience function to setup a closed bank account.

  ## Parameters

    * `account_number` - The account number
    * `final_balance` - The balance before closing (default: 0)

  ## Examples

      setup_closed_bank_account("account-123", 0)
  """
  def setup_closed_bank_account(account_number, final_balance \\ 0) do
    event =
      bank_account_opened(
        account_number: account_number,
        initial_balance: final_balance
      )

    stream_id = "bank-account-#{event.id}"

    events = [
      event,
      bank_account_closed(account_number: account_number)
    ]

    append_events(stream_id, events)

    # Give time for projections to process
    Process.sleep(50)

    BankingApi.Repo.get!(BankingApi.BankAccounts.Projections.BankAccount, event.id)
  end

  # Private helpers

  defp to_event_data(event, metadata) do
    %EventStore.EventData{
      event_type: Atom.to_string(event.__struct__),
      data: event,
      metadata:
        Map.merge(metadata, %{
          causation_id: Ecto.UUID.generate(),
          correlation_id: Ecto.UUID.generate()
        })
    }
  end
end
