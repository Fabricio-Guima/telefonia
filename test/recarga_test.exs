defmodule RecargaTest do
  use ExUnit.Case
  # doctest Recarga

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test("deve realizar uma recarga") do
    {:ok, _mensagem} = Assinante.cadastrar("FSG", "159", "123456", :prepago)

    assinante = Assinante.buscar_assinante("159", :prepago)

    assert Recarga.nova(DateTime.utc_now(), 30, assinante.numero) ==
             {:ok, "Recarga realizada com sucesso!"}

    assinante_atualizado = Assinante.buscar_assinante(assinante.numero, :prepago)
    assert assinante_atualizado.plano.creditos == 30
    assert Enum.count(assinante_atualizado.plano.recargas) == 1
  end

  test "deve criar uma estrutura de recarga" do
    recarga = %Recarga{data: ~U[2025-03-26T12:00:00Z], valor: 50}

    assert recarga.data == ~U[2025-03-26T12:00:00Z]
    assert recarga.valor == 50
  end

end
