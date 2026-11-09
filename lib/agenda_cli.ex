defmodule AgendaCli do
  alias AgendaCli.{Contacts, Store}

  @ajuda """
  ---------------------------------------------------------------------
  Agenda CLI
  ---------------------------------------------------------------------
  add --name <nome> --company <empresa> --phone <tel> --email <email>
  edit <id> --phone <tel>  : Edita um ou mais campos
  del <id>                 : Remove um contato
  show <id>                : Mostra um contato
  list                     : Lista os contatos
  search --name <valor>    : Busca por --name, --phone, --company ou --email
  help                     : Mostra os comandos do cli
  exit                     : Finaliza o CLI
  ---------------------------------------------------------------------
  """

  def main(_args \\ []) do
    IO.puts(@ajuda)
    loop(Store.load())
  end

  def loop(contatos) do
    input = IO.gets("agenda> ") |> ler()
    case parse(input) do
      {:add, contato} when is_map(contato) ->
        if Map.has_key?(contato, :name) do
          novos = Contacts.add(contatos, contato, System.system_time(:millisecond))
          Store.save(novos)
          IO.puts("   Contato \"#{contato.name}\" cadastrado com sucesso.")
          loop(novos)
        else
          IO.puts("   O nome é obrigatório.")
          loop(contatos)
        end

      {:del, id} when is_integer(id) ->
        if Contacts.find(contatos, id) do
          novos = Contacts.delete(contatos, id)
          Store.save(novos)
          IO.puts("   Contato ##{id} removido.")
          loop(novos)
        else
          IO.puts("   Contato ##{id} não encontrado.")
          loop(contatos)
        end

      {:edit, id, alteracoes} when is_integer(id) and is_map(alteracoes) ->
        if Contacts.find(contatos, id) do
          novos = Contacts.edit(contatos, id, alteracoes)
          Store.save(novos)
          IO.puts("   Contato ##{id} atualizado com sucesso.")
          loop(novos)
        else
          IO.puts("   Contato ##{id} não encontrado.")
          loop(contatos)
        end

      {:show, id} when is_integer(id) ->
        case Contacts.find(contatos, id) do
          nil -> IO.puts("   Contato ##{id} não encontrado.")
          contato -> imprimir([contato])
        end

        loop(contatos)

      :list ->
        imprimir(contatos)
        loop(contatos)

      :help ->
        IO.puts(@ajuda)
        loop(contatos)

      {:search, {campo, valor}} ->
        contatos
        |> Contacts.search(campo, valor)
        |> imprimir()

        loop(contatos)

      :exit ->
        IO.puts("Até mais!")

      _ ->
        IO.puts("Comando inválido, tente novamente.")
        loop(contatos)
    end
  end

  defp ler(:eof), do: "exit"
  defp ler(texto), do: String.trim(texto)

  defp imprimir([]), do: IO.puts("   Nenhum contato encontrado.")

  defp imprimir(contatos) do
    IO.puts("---------------------------------------------------------------------")

    Enum.each(contatos, fn c ->
      IO.puts("   #{c.id} - #{c.name} - #{c.company} - #{c.phone} - #{c.email}")
    end)

    IO.puts("---------------------------------------------------------------------")
  end

  def parse("add " <> flags) do
    {:add, parse_flags(flags)}
  end

  def parse("del " <> id) do
    {:del, parse_id(id)}
  end

  def parse("edit " <> resto) do
    case String.split(resto, " ", parts: 2) do
      [id, flags] -> {:edit, parse_id(id), parse_flags(flags)}
      _ -> :unknown
    end
  end

  def parse("show " <> id) do
    {:show, parse_id(id)}
  end

  def parse("search " <> flags) do
    {:search, parse_search(flags)}
  end

  def parse("list") do
    :list
  end

  def parse("help") do
    :help
  end

  def parse("exit") do
    :exit
  end

  def parse(_) do
    :unknown
  end

  def parse_search("--name " <> valor), do: {:name, String.trim(valor)}
  def parse_search("--phone " <> valor), do: {:phone, String.trim(valor)}
  def parse_search("--company " <> valor), do: {:company, String.trim(valor)}
  def parse_search("--email " <> valor), do: {:email, String.trim(valor)}
  def parse_search(_), do: :unknown

  defp parse_id(texto) do
    case Integer.parse(String.trim(texto)) do
      {id, ""} -> id
      _ -> :unknown
    end
  end

  defp parse_flags("--" <> _ = texto) do
    pares =
      texto
      |> String.split("--", trim: true)
      |> Enum.map(&parse_flag/1)

    if Enum.member?(pares, :unknown), do: :unknown, else: Map.new(pares)
  end

  defp parse_flags(_), do: :unknown

  defp parse_flag(texto) do
    case String.split(String.trim(texto), " ", parts: 2) do
      [nome, valor] -> campo(nome, String.trim(valor))
      _ -> :unknown
    end
  end

  defp campo("name", valor), do: {:name, valor}
  defp campo("company", valor), do: {:company, valor}
  defp campo("phone", valor), do: {:phone, valor}
  defp campo("email", valor), do: {:email, valor}
  defp campo(_, _), do: :unknown
end
