defmodule ChamadaTest do
  use ExUnit.Case

  test "deve testar a estrtura para a cobertura de testes" do
    assert %Chamada{data: DateTime.utc_now(), duracao: 30}.duracao == 30
  end
end
