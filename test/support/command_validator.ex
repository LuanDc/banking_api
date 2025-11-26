defmodule BankingApi.CommandValidator do
  alias BankingApi.Support.Middleware.Validate
  alias Commanded.Middleware.Pipeline

  def validate(command) when is_struct(command) do
    pipeline = %Pipeline{command: command}
    Validate.before_dispatch(pipeline)
  end
end
