defmodule BankingApi.Repo.Migrations.AddCompositeIndexesToTransactions do
  use Ecto.Migration

  def change do
    # Índice composto para account_number + date (descendente)
    # Otimiza a query principal de listagem com ordenação e paginação
    create index(:transactions, [:account_number, "date DESC"])
  end
end
