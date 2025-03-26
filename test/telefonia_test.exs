defmodule TelefoniaTest do
  use ExUnit.Case
  doctest Telefonia
  import ExUnit.CaptureIO

  # Inicia o sistema antes de cada teste
  setup do
    Telefonia.start()

    on_exit(fn ->
      # Limpa os arquivos gerados durante os testes
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "Cadastro de Assinantes" do
    test "deve cadastrar um novo assinante prepago" do
      assert {:ok, _msg} = Telefonia.cadastrar_assinante("FSG", "159", "123456", :prepago)
      assinante = Assinante.buscar_assinante("159", :prepago)
      assert assinante != nil
      assert assinante.nome == "FSG"
      assert assinante.numero == "159"
      assert %Prepago{} = assinante.plano
    end

    test "deve cadastrar um novo assinante pospago" do
      assert {:ok, _msg} = Telefonia.cadastrar_assinante("FSG", "160", "123456", :pospago)
      assinante = Assinante.buscar_assinante("160", :pospago)
      assert assinante != nil
      assert assinante.nome == "FSG"
      assert assinante.numero == "160"
      assert %Pospago{} = assinante.plano
    end

    test "não deve permitir cadastrar assinante com número já existente" do
      Telefonia.cadastrar_assinante("FSG", "159", "123456", :prepago)
      assert {:error, "Assinante com este número cadastrado"} = Telefonia.cadastrar_assinante("FSG", "159", "654321", :prepago)
    end
  end

  describe "Realização de Chamadas" do
    test "deve realizar chamada para assinante prepago com saldo suficiente" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      Recarga.nova(DateTime.utc_now(), 20, "159")  # Realizando uma recarga
      assert {:ok, "A chamada custou 5, e você tem 15 de créditos"} = Telefonia.fazer_chamada("159", :prepago, DateTime.utc_now(), 5)
    end

    test "não deve realizar chamada para assinante prepago sem saldo" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      assert {:error, "Você não tem créditos para fazer a ligação. Faça uma recarga"} = Telefonia.fazer_chamada("159", :prepago, DateTime.utc_now(), 5)
    end

    test "deve realizar chamada para assinante pospago" do
      Assinante.cadastrar("FSG", "160", "123456", :pospago)
      assert {:ok, "Chamada feita com sucesso! duração: 5 minutos"} = Telefonia.fazer_chamada("160", :pospago, DateTime.utc_now(), 5)
    end
  end

  describe "Recargas" do
    test "deve realizar recarga com sucesso para prepago" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      assert {:ok, "Recarga realizada com sucesso!"} = Telefonia.recarga("159", DateTime.utc_now(), 20)
      assinante = Assinante.buscar_assinante("159", :prepago)
      assert Enum.count(assinante.plano.recargas) == 1
      assert Enum.at(assinante.plano.recargas, 0).valor == 20
    end
  end

  describe "Busca de Assinantes" do
    test "deve buscar assinante por número" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      assinante = Telefonia.buscar_por_numero("159", :prepago)
      assert assinante != nil
      assert assinante.numero == "159"
    end

    test "deve retornar nil para número não encontrado" do
      assert Telefonia.buscar_por_numero("999", :prepago) == nil
    end
  end

  describe "Impressão de Contas" do
    # test "deve imprimir contas corretamente para prepago" do
    #   Assinante.cadastrar("FSG", "159", "123456", :prepago)
    #   Recarga.nova(DateTime.utc_now(), 20, "159")
    #   Telefonia.fazer_chamada("159", :prepago, DateTime.utc_now(), 5)

    #   # Buscar assinante para garantir persistência dos dados
    #   assinante = Assinante.buscar_assinante("159", :prepago)
    #   assert length(assinante.chamadas) == 1  # Garante que a chamada foi registrada

    #   # Agora, imprimir a conta e testar a saída
    #   output = capture_io(fn -> Telefonia.imprimir_contas(2, 2025) end)
    #   assert output =~ "Conta prepago do Assinante: FSG"
    #   assert output =~ "Total de chamadas: 1"
    #   assert output =~ "Total de recargas: 1"
    # end


    test "deve imprimir contas corretamente para pospago" do
      Assinante.cadastrar("FSG", "160", "123456", :pospago)
      assert capture_io(fn -> Telefonia.imprimir_contas(2, 2025) end) =~ "Conta pospaga do Assinante: FSG"
    end

    test "deve imprimir contas vazias para planos não existentes" do
      Assinante.cadastrar("FSG", "161", "123456", :prepago)

      assert capture_io(fn -> Telefonia.imprimir_contas(12, 2025) end) =~ "Conta prepago do Assinante: FSG"
      assert capture_io(fn -> Telefonia.imprimir_contas(12, 2025) end) =~ "Número: 161"
      assert capture_io(fn -> Telefonia.imprimir_contas(12, 2025) end) =~ "Total de chamadas: 0"
      assert capture_io(fn -> Telefonia.imprimir_contas(12, 2025) end) =~ "Total de recargas: 0"
    end
  end

  describe "Listagem de Assinantes" do
    test "deve listar assinantes prepago" do
      Assinante.cadastrar("FSG", "159", "123456", :prepago)
      assinantes = Telefonia.listar_assinantes_prepago()
      assert length(assinantes) == 1
      assert Enum.any?(assinantes, fn a -> a.numero == "159" end)
    end

    test "deve listar assinantes pospago" do
      Assinante.cadastrar("FSG", "160", "123456", :pospago)
      assinantes = Telefonia.listar_assinantes_pospago()
      assert length(assinantes) == 1
      assert Enum.any?(assinantes, fn a -> a.numero == "160" end)
    end

  end
end
