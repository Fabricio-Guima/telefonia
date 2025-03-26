defmodule AssinanteTest do
  use ExUnit.Case
  doctest Assinante

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "testes responsáveis pelo cadastro de assinantes" do
    test "deve retornar estrutura de assinante" do
      assert %Assinante{nome: "teste", numero: "147", cpf: "124456", plano: "plano"}.nome ==
               "teste"
    end

    test "criar uma conta prepago" do
      assert Assinante.cadastrar("fafa", "123", "123456", :prepago) ==
               {:ok, "Assinante fafa cadastrado com sucesso!"}
    end

    test "deve retornar erro dizendo que assinante já está cadastrado" do
      Assinante.cadastrar("fafa", "123", "123456", :prepago)

      assert Assinante.cadastrar("fafa", "123", "123456", :prepago) ==
               {:error, "Assinante com este número cadastrado"}
    end
  end

  describe "testes responsáveis pela busca de assinantes" do
    test "busca pospago" do
      Assinante.cadastrar("fafa", "123", "123456", :pospago)

      assert Assinante.buscar_assinante("123", :pospago).plano.__struct__ == Pospago
    end

    test "busca prepago" do
      Assinante.cadastrar("tata", "12", "123456", :prepago)

      assert Assinante.buscar_assinante("12", :prepago).nome == "tata"
      assert Assinante.buscar_assinante("12", :prepago).plano.__struct__ == Prepago
    end
  end

  describe "delete" do
    test "deve deletar um assinante" do
      Assinante.cadastrar("tata", "12", "123456", :prepago)
      Assinante.cadastrar("tata 2", "123", "123456", :prepago)

      assert Assinante.deletar("12") == {:ok, "Assinante tata deletado!"}
    end
  end

  describe "testes de atualização de assinante" do
    test "deve atualizar um assinante mantendo o mesmo plano" do
      Assinante.cadastrar("tata", "12", "123456", :prepago)
      assinante = Assinante.buscar_assinante("12")
      novo_assinante = %Assinante{assinante | nome: "tata atualizado"}
      Assinante.atualizar("12", novo_assinante)
      assert Assinante.buscar_assinante("12").nome == "tata atualizado"
    end

    test "não deve permitir alterar o tipo de plano do assinante" do
      Assinante.cadastrar("tata", "12", "123456", :prepago)
      assinante = Assinante.buscar_assinante("12")
      novo_assinante = %Assinante{assinante | plano: %Pospago{}}
      assert Assinante.atualizar("12", novo_assinante) == {:erro, "Assinante não pode alterar o plano"}
    end
  end
end
