defmodule AgendaCli.Contacts do

  def add(contatos, contato, id) do
    novo =
      %{name: "", company: "", phone: "", email: ""}
      |> Map.merge(contato)
      |> Map.put(:id, id)

    contatos ++ [novo]
  end

  def find(contatos, id) do
    Enum.find(contatos, fn contato -> contato.id == id end)
  end

  def delete(contatos, id) do
    Enum.reject(contatos, fn contato -> contato.id == id end)
  end

  def edit(contatos, id, alteracoes) do
    Enum.map(contatos, fn contato ->
      if contato.id == id do
        Map.merge(contato, alteracoes)
      else
        contato
      end
    end)
  end

  def search(contatos, campo, valor) do
    valor = String.downcase(valor)

    Enum.filter(contatos, fn contato ->
      contato
      |> Map.get(campo)
      |> String.downcase()
      |> String.contains?(valor)
    end)
  end
end
