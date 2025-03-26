defmodule Assinante do
  @moduledoc """
  Módulo responsável pelo gerenciamento de assinantes, permitindo operações de cadastro, busca, atualização e remoção.
  Suporta assinantes `prepago` e `pospago`.
  """

  defstruct [:nome, :numero, :cpf, :plano, chamadas: []]

  @assinantes %{:prepago => "pre.txt", :pospago => "pos.txt"}

  @doc """
  Busca um assinante pelo número, podendo filtrar por tipo de plano.

  ## Parâmetros
  - `numero`: Número do assinante a ser buscado.
  - `key`: Tipo de plano (`:prepago`, `:pospago` ou `:all` para buscar em ambos). Padrão: `:all`.

  ## Retorno
  - Retorna o assinante encontrado ou `nil` se não existir.
  """
  def buscar_assinante(numero, key \\ :all), do: buscar(numero, key)

  defp buscar(numero, :prepago), do: filtro(assinantes_prepago(), numero)
  defp buscar(numero, :pospago), do: filtro(assinantes_pospago(), numero)
  defp buscar(numero, :all), do: filtro(assinantes(), numero)

  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero == numero))

  @doc """
  Retorna a lista de assinantes do plano `prepago`.
  """
  def assinantes_prepago(), do: read(:prepago)

  @doc """
  Retorna a lista de assinantes do plano `pospago`.
  """
  def assinantes_pospago(), do: read(:pospago)

  @doc """
  Retorna a lista de todos os assinantes cadastrados.
  """
  def assinantes(), do: read(:prepago) ++ read(:pospago)

  @doc """
  Cadastra um novo assinante, verificando se o número já existe.

  ## Parâmetros
  - `nome`: Nome do assinante.
  - `numero`: Número único do assinante.
  - `cpf`: CPF do assinante.
  - `plano`: Tipo de plano (`:prepago` ou `:pospago`).

  ## Retorno
  - `{:ok, "Mensagem de sucesso"}` se o cadastro for realizado.
  - `{:error, "Mensagem de erro"}` se o número já existir.
  """
  def cadastrar(nome, numero, cpf, :prepago), do: cadastrar(nome, numero, cpf, %Prepago{})
  def cadastrar(nome, numero, cpf, :pospago), do: cadastrar(nome, numero, cpf, %Pospago{})

  def cadastrar(nome, numero, cpf, plano) do
    case buscar_assinante(numero) do
      nil ->
        assinante = %__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}
        (read(pega_plano(assinante)) ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante))

        {:ok, "Assinante #{nome} cadastrado com sucesso!"}
      _ ->
        {:error, "Assinante com este número cadastrado"}
    end
  end

  @doc """
  Atualiza os dados de um assinante existente.

  ## Parâmetros
  - `numero`: Número do assinante a ser atualizado.
  - `assinante`: Estrutura do assinante com os novos dados.

  ## Retorno
  - Se o plano for o mesmo, atualiza os dados.
  - Se o plano for diferente, retorna erro.
  """
  def atualizar(numero, assinante) do
    {assinante_antigo, nova_lista} = deletar_item(numero)

    case assinante.plano.__struct__ == assinante_antigo.plano.__struct__ do
      true ->
        (nova_lista ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante))
      false ->
        {:erro, "Assinante não pode alterar o plano"}
    end
  end

  @doc """
  Remove um assinante pelo número.

  ## Parâmetros
  - `numero`: Número do assinante a ser removido.

  ## Retorno
  - `{:ok, "Mensagem de sucesso"}` se o assinante for removido.
  - `{:error, "Mensagem de erro"}` se o assinante não for encontrado.
  """
  def deletar(numero) do
    assinante = buscar_assinante(numero)

    case assinante do
      nil -> {:error, "Assinante não encontrado"}
      _ ->
        tipo_plano = pega_plano(assinante)
        lista_atualizada = Enum.reject(read(tipo_plano), fn a -> a.numero == numero end)
        lista_atualizada |> :erlang.term_to_binary() |> write(tipo_plano)
        {:ok, "Assinante #{assinante.nome} deletado!"}
    end
  end

  defp deletar_item(numero) do
    assinante = buscar_assinante(numero)
    nova_lista = read(pega_plano(assinante)) |> List.delete(assinante)
    {assinante, nova_lista}
  end

  defp pega_plano(assinante) do
    case assinante.plano.__struct__ == Prepago do
      true -> :prepago
      false -> :pospago
    end
  end

  defp write(lista_assinantes, plano) do
    File.write!(@assinantes[plano], lista_assinantes)
  end

  @doc """
  Lê a lista de assinantes de um determinado plano a partir do arquivo.

  ## Parâmetros
  - `plano`: Tipo do plano (`:prepago` ou `:pospago`).

  ## Retorno
  - Retorna uma lista de assinantes do plano informado.
  """
  def read(plano) do
    case File.read(@assinantes[plano]) do
      {:ok, assinantes} ->
        case :erlang.binary_to_term(assinantes) do
          lista when is_list(lista) -> lista
          item -> [item]
        end
      {:error, _} -> []
    end
  end
end
