defmodule Pospago do
  @moduledoc """
  Módulo responsável pela lógica do plano pós-pago, incluindo registro de chamadas e cálculo da conta mensal.
  """

  defstruct valor: 0

  @custo_minuto 1

  @doc """
  Realiza uma chamada para um assinante pós-pago.

  ## Parâmetros
  - `numero`: Número do assinante.
  - `data`: Data da chamada.
  - `duracao`: Duração da chamada em minutos.

  ## Retorno
  - `{:ok, mensagem}` indicando que a chamada foi registrada com sucesso.
  """
  def fazer_chamada(numero, data, duracao) do
    Assinante.buscar_assinante(numero, :pospago)
    |> Chamada.registrar(data, duracao)
    {:ok, "Chamada feita com sucesso! duração: #{duracao} minutos"}
  end

  @doc """
  Gera a conta do assinante pós-pago para um determinado mês e ano.

  ## Parâmetros
  - `mes`: Mês desejado para a conta.
  - `ano`: Ano desejado para a conta.
  - `numero`: Número do assinante.

  ## Retorno
  - Estrutura do assinante com o valor total calculado das chamadas realizadas no período.
  """
  def imprimir_conta(mes, ano, numero) do
    assinante = Contas.imprimir(mes, ano, numero, :pospago)

    valor_total = assinante.chamadas
    |> Enum.map(&(&1.duracao * @custo_minuto))
    |> Enum.sum()

    %Assinante{assinante | plano: %__MODULE__{valor: valor_total}}
  end
end
