defmodule Prepago do
  defstruct creditos: 0, recargas: []
  @preco_minuto 1
  def fazer_chamada(numero, data, duracao) do
    assinante = Assinante.buscar_assinante(numero, :prepago)
    custo = @preco_minuto * duracao

    cond do
      custo <= assinante.plano.creditos ->
        plano = assinante.plano
        plano = %__MODULE__{plano | creditos: plano.creditos - custo}

        %Assinante{assinante | plano: plano}
        |> Chamada.registrar(data, duracao)

        {:ok, "A chamada custou #{custo}, e você tem #{plano.creditos} de créditos"}

      true ->
        {:error, "Você não tem créditos para fazer a ligação. Faça uma recarga"}
    end
  end

  def imprimir_conta(mes, ano, numero) do
    Contas.imprimir(mes, ano, numero, :prepago)
  end
end
