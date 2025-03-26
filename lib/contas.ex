defmodule Contas do
  @moduledoc """
  Módulo responsável pela geração de contas de assinantes, filtrando chamadas e recargas por mês e ano.
  """

  @doc """
  Gera um extrato das chamadas e recargas do assinante em um determinado mês e ano.

  ## Parâmetros
  - `mes`: Mês desejado para o extrato.
  - `ano`: Ano desejado para o extrato.
  - `numero`: Número do assinante.
  - `plano`: Tipo do plano (`:prepago` ou `:pospago`).

  ## Retorno
  - Estrutura do assinante com chamadas e recargas filtradas pelo período.
  """
  def imprimir(mes, ano, numero, plano) do
    assinante = Assinante.buscar_assinante(numero)
    chamadas_do_mes = buscar_elementos_mes(assinante.chamadas, mes, ano)

    cond do
      plano == :prepago ->
        recarga_do_mes = buscar_elementos_mes(assinante.plano.recargas, mes, ano)
        plano_atualizado = %Prepago{assinante.plano | recargas: recarga_do_mes}
        %Assinante{assinante | chamadas: chamadas_do_mes, plano: plano_atualizado}

      plano == :pospago ->
        %Assinante{assinante | chamadas: chamadas_do_mes}
    end
  end

  @doc """
  Filtra elementos de uma lista (chamadas ou recargas) que pertencem ao mês e ano especificados.

  ## Parâmetros
  - `elementos`: Lista de elementos contendo a chave `data`.
  - `mes`: Mês desejado para o filtro.
  - `ano`: Ano desejado para o filtro.

  ## Retorno
  - Lista de elementos filtrados.
  """
  def buscar_elementos_mes(elementos, mes, ano) do
    elementos
    |> Enum.filter(fn elemento ->
      elemento.data.year == ano && elemento.data.month == mes
    end)
  end
end
