defmodule PrepagoTest do
  use ExUnit.Case
  doctest Prepago

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "deve retornar estrutura de prepago" do
    assert %Prepago{creditos: 10, recargas: []}
  end

  describe "Funções de Ligação" do
    test "Fazer uma ligação" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      Recarga.nova(DateTime.utc_now(), 10, "159")

      assert Prepago.fazer_chamada("159", DateTime.utc_now(), 3) ==
               {:ok, "A chamada custou 3, e você tem 7 de créditos"}
    end

    test "Fazer uma ligação longa e não tem créditos o suficiente" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)

      assert Prepago.fazer_chamada("159", DateTime.utc_now(), 11) ==
               {:error, "Você não tem créditos para fazer a ligação. Faça uma recarga"}
    end
  end

  describe "Testes para impressão de contas" do
    test "deve informar valores da conta do mês" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      data = DateTime.utc_now()
      data_antiga = ~U[2025-02-23 15:04:41.340024Z]
      Recarga.nova(data, 10, "159")
      Prepago.fazer_chamada("159", data, 3)

      Recarga.nova(data_antiga, 10, "159")
      Prepago.fazer_chamada("159", data_antiga, 3)

      assinante = Assinante.buscar_assinante("159", :prepago)

      assert Enum.count(assinante.chamadas) == 2
      assert Enum.count(assinante.plano.recargas) == 2

      assinante = Prepago.imprimir_conta(data.month, data.year, "159")

      assert assinante.numero == "159"
      assert Enum.count(assinante.chamadas) == 1
      assert Enum.count(assinante.plano.recargas) == 1
    end
  end
end
