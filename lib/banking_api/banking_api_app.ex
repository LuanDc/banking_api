defmodule BankingApi.BankingApiApp do
  use Commanded.Application, otp_app: :banking_api

  router(BankingApi.Router)
end
