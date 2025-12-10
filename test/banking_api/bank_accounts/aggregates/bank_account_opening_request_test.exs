defmodule BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequestTest do
  use BankingApi.DataCase

  alias BankingApi.BankAccounts.Aggregates.BankAccountOpeningRequest
  alias BankingApi.BankAccounts.Commands.RequestBankAccountOpening
  alias BankingApi.BankAccounts.Events.BankAccountOpeningRequested

  describe "execute/2 - RequestBankAccountOpening" do
    test "creates BankAccountOpeningRequested event when aggregate is new" do
      request_id = Ecto.UUID.generate()
      id = Ecto.UUID.generate()
      account_number = "TEST-001"

      command = %RequestBankAccountOpening{
        request_id: request_id,
        id: id,
        account_number: account_number,
        initial_balance: 1000,
        status: "active"
      }

      aggregate = %BankAccountOpeningRequest{request_id: nil}

      assert %BankAccountOpeningRequested{
               id: ^id,
               request_id: ^request_id,
               account_number: ^account_number,
               initial_balance: 1000,
               status: "active"
             } = BankAccountOpeningRequest.execute(aggregate, command)
    end

    test "returns error when opening request already exists" do
      request_id = Ecto.UUID.generate()
      id = Ecto.UUID.generate()

      command = %RequestBankAccountOpening{
        request_id: request_id,
        id: id,
        account_number: "TEST-001",
        initial_balance: 1000,
        status: "active"
      }

      aggregate = %BankAccountOpeningRequest{
        request_id: request_id,
        id: id,
        account_number: "TEST-001",
        initial_balance: 1000,
        status: "active"
      }

      assert {:error, :bank_account_opening_already_requested} =
               BankAccountOpeningRequest.execute(aggregate, command)
    end
  end

  describe "apply/2 - BankAccountOpeningRequested" do
    test "updates aggregate state with event data" do
      id = Ecto.UUID.generate()
      request_id = Ecto.UUID.generate()
      account_number = "TEST-002"

      event = %BankAccountOpeningRequested{
        id: id,
        request_id: request_id,
        account_number: account_number,
        initial_balance: 2000,
        status: "inactive"
      }

      aggregate = %BankAccountOpeningRequest{id: nil}

      result = BankAccountOpeningRequest.apply(aggregate, event)

      assert %BankAccountOpeningRequest{
               id: ^id,
               request_id: ^request_id,
               account_number: ^account_number,
               initial_balance: 2000,
               status: "inactive"
             } = result
    end
  end
end
