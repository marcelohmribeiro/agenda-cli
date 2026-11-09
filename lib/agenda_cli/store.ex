defmodule AgendaCli.Store do

  @file_path "contacts.json"

  def load do
    case File.read(@file_path) do
      {:ok, content} ->
        content
        |> Jason.decode!
        |> Enum.map(fn c ->
          %{
            id: c["id"],
            name: c["name"] || "",
            company: c["company"] || "",
            phone: c["phone"] || "",
            email: c["email"] || ""
          }
        end)
      {:error, _} ->
        []
    end
  end

  def save(contatos) do
    contatos
    |> Jason.encode!(pretty: true)
    |> then(&File.write!(@file_path, &1))
  end

end
