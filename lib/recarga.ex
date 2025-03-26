defmodule Recarga do
  @moduledoc """
  Módulo responsável pelo registro de recargas para assinantes do plano pré-pago.
  """

  defstruct data: nil, valor: nil

  @doc """
  Realiza uma nova recarga para um assinante pré-pago.

  ## Parâmetros
  - `data`: Data da recarga.
  - `valor`: Valor da recarga.
  - `numero`: Número do assinante.

  ## Retorno
  - `{:ok, mensagem}` confirmando que a recarga foi realizada com sucesso.
  """
  def nova(data, valor, numero) do
    assinante = Assinante.buscar_assinante(numero, :prepago)
    plano = assinante.plano

    plano = %Prepago{
      plano
      | creditos: plano.creditos + valor,
        recargas: plano.recargas ++ [%__MODULE__{data: data, valor: valor}]
    }

    assinante = %Assinante{assinante | plano: plano}
    Assinante.atualizar(numero, assinante)
    {:ok, "Recarga realizada com sucesso!"}
  end
end
