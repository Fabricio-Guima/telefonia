defmodule Chamada do
  @moduledoc """
  Módulo responsável pelo registro de chamadas realizadas pelos assinantes.
  """

  defstruct data: nil, duracao: nil

  @doc """
  Registra uma nova chamada para um assinante.

  ## Parâmetros
  - `assinante`: Estrutura do assinante que realizou a chamada.
  - `data`: Data da chamada.
  - `duracao`: Duração da chamada em minutos.

  ## Retorno
  - Atualiza a lista de chamadas do assinante e salva a alteração.
  """
  def registrar(assinante, data, duracao) do
    assinante_atualizado = %Assinante{
      assinante
      | chamadas: assinante.chamadas ++ [%__MODULE__{data: data, duracao: duracao}]
    }

    assinante = Assinante.atualizar(assinante.numero, assinante_atualizado)
    IO.inspect(assinante)
  end
end
