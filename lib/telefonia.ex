defmodule Telefonia do
  @moduledoc """
  Módulo principal responsável por gerenciar assinantes, chamadas, recargas e contas na operadora.
  """

  @doc """
  Inicializa o sistema criando arquivos para armazenar os assinantes pré-pagos e pós-pagos.
  """
  def start do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))
  end

  @doc """
  Cadastra um novo assinante no sistema.

  ## Parâmetros
  - `nome`: Nome do assinante.
  - `numero`: Número do assinante.
  - `cpf`: CPF do assinante.
  - `plano`: Tipo de plano (`:prepago` ou `:pospago`).

  ## Retorno
  - `{:ok, mensagem}` se o cadastro for bem-sucedido.
  - `{:error, mensagem}` se o número já estiver cadastrado.
  """
  def cadastrar_assinante(nome, numero, cpf, plano) do
    Assinante.cadastrar(nome, numero, cpf, plano)
  end

  @doc """
  Lista todos os assinantes cadastrados.
  """
  def listar_assinantes, do: Assinante.assinantes()

  @doc """
  Lista todos os assinantes do plano pré-pago.
  """
  def listar_assinantes_prepago, do: Assinante.assinantes_prepago()

  @doc """
  Lista todos os assinantes do plano pós-pago.
  """
  def listar_assinantes_pospago, do: Assinante.assinantes_pospago()

  @doc """
  Realiza uma chamada para um assinante, verificando o tipo de plano.

  ## Parâmetros
  - `numero`: Número do assinante.
  - `plano`: Tipo de plano (`:prepago` ou `:pospago`).
  - `data`: Data da chamada.
  - `duracao`: Duração da chamada em minutos.

  ## Retorno
  - `{:ok, mensagem}` se a chamada for realizada com sucesso.
  - `{:error, mensagem}` caso não seja possível completar a chamada.
  """
  def fazer_chamada(numero, plano, data, duracao) do
    cond do
      plano == :prepago -> Prepago.fazer_chamada(numero, data, duracao)
      plano == :pospago -> Pospago.fazer_chamada(numero, data, duracao)
    end
  end

  @doc """
  Realiza uma recarga para um assinante do plano pré-pago.

  ## Parâmetros
  - `numero`: Número do assinante.
  - `data`: Data da recarga.
  - `valor`: Valor da recarga.
  """
  def recarga(numero, data, valor) do
    Recarga.nova(data, valor, numero)
  end

  @doc """
  Busca um assinante pelo número, podendo filtrar por tipo de plano.

  ## Parâmetros
  - `numero`: Número do assinante.
  - `plano` (opcional): Tipo de plano (`:prepago`, `:pospago` ou `:all`, que busca em ambos). O padrão é `:all`.

  ## Retorno
  - O assinante encontrado ou `nil` caso não exista.
  """
  def buscar_por_numero(numero, plano \\ :all), do: Assinante.buscar_assinante(numero, plano)

  @doc """
  Imprime as contas de todos os assinantes, separando por plano e detalhando chamadas e recargas.

  ## Parâmetros
  - `mes`: Mês da conta.
  - `ano`: Ano da conta.
  """
  def imprimir_contas(mes, ano) do
    Assinante.assinantes_prepago()
    |> Enum.each(fn assinante ->
      assinante = Prepago.imprimir_conta(mes, ano, assinante.numero)
      IO.puts "Conta prepago do Assinante: #{assinante.nome}"
      IO.puts "Número: #{assinante.numero}"
      IO.puts "Chamadas: "
      IO.inspect(assinante.chamadas)
      IO.puts "Recargas: "
      IO.inspect(assinante.plano.recargas)
      IO.puts "Total de chamadas: #{Enum.count(assinante.chamadas)}"
      IO.puts "Total de recargas: #{Enum.count(assinante.plano.recargas)}"
      IO.puts "============================================================"
    end)

    Assinante.assinantes_pospago()
    |> Enum.each(fn assinante ->
      assinante = Pospago.imprimir_conta(mes, ano, assinante.numero)
      IO.puts "Conta pospaga do Assinante: #{assinante.nome}"
      IO.puts "Número: #{assinante.numero}"
      IO.puts "Chamadas: "
      IO.inspect(assinante.chamadas)
      IO.puts "Total de chamadas: #{Enum.count(assinante.chamadas)}"
      IO.puts "Total de fatura: #{assinante.plano.valor}"
      IO.puts "============================================================"
    end)
  end
end
