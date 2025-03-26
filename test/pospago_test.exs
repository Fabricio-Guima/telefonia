defmodule PospagoTest do
  use ExUnit.Case
  doctest Pospago

  setup do
    # Inicializa os arquivos para simular o ambiente
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      # Limpeza após os testes
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "deve fazer uma ligação" do
    # Cadastra o assinante
    Assinante.cadastrar("FSG", "156", "123456", :pospago)

    # Verifica se a chamada foi feita com sucesso
    assert Pospago.fazer_chamada("156", DateTime.utc_now(), 5) ==
             {:ok, "Chamada feita com sucesso! duração: 5 minutos"}
  end

  test "deve imprimir a conta do assinante" do
    # Cadastra o assinante
    Assinante.cadastrar("FSG", "156", "123456", :pospago)

    # Realiza algumas chamadas
    data = DateTime.utc_now()
    data_antiga = ~U[2025-02-23 15:04:41.340024Z]

    Pospago.fazer_chamada("156", data, 3)
    Pospago.fazer_chamada("156", data_antiga, 3)
    Pospago.fazer_chamada("156", data, 3)
    Pospago.fazer_chamada("156", data, 3)

    # Verifica se as chamadas foram registradas
    assinante = Assinante.buscar_assinante("156", :pospago)
    assert Enum.count(assinante.chamadas) == 4

    # Imprime a conta do assinante para o mês e ano da data
    assinante = Pospago.imprimir_conta(data.month, data.year, "156")

    # Verifica se a conta foi impressa corretamente
    assert assinante.numero == "156"
    assert Enum.count(assinante.chamadas) == 3  # A conta deve conter apenas chamadas do mês em questão
    assert assinante.plano.valor == 9  # 3 chamadas de 3 minutos custando 1 por minuto
  end
end
