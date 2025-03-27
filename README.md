# Telefonia - Sistema de Gestão de Assinantes

## Visão Geral
O projeto **Telefonia** é um sistema desenvolvido em Elixir para gerenciar assinantes de planos **pré-pago** e **pós-pago**. O sistema permite realizar operações como cadastro, busca, chamadas, recargas e geração de contas.

Diferente de sistemas convencionais que utilizam bancos de dados, este projeto **não possui banco de dados**. Em vez disso, os dados dos assinantes são armazenados e manipulados em arquivos **TXT** para simular tabelas.

O projeto **não utiliza Docker**, sendo necessário configurar um ambiente Elixir para executá-lo.

## Funcionalidades
- **Gerenciamento de assinantes**: Cadastro, busca, atualização e remoção de assinantes.
- **Registro de chamadas**: Simulação de ligações para assinantes pré e pós-pago.
- **Recargas**: Adição de créditos para assinantes do plano pré-pago.
- **Geração de contas**: Relatórios mensais de chamadas e recargas.
- **Estrutura modular**: Código dividido em módulos especializados para melhor organização.

## Estrutura do Projeto
O sistema é composto pelos seguintes módulos principais:
- **Assinante**: Gerencia assinantes, permitindo cadastro, busca e atualização.
- **Chamada**: Registra chamadas realizadas pelos assinantes.
- **Contas**: Gera extratos mensais de chamadas e recargas.
- **Pospago**: Implementa a lógica de cobrança do plano pós-pago.
- **Prepago**: Implementa a lógica de uso de créditos para assinantes pré-pagos.
- **Recarga**: Realiza recargas para assinantes pré-pagos.
- **Telefonia**: Módulo principal para interação com o sistema.

## Instalação e Configuração
Para rodar o projeto, é necessário ter **Elixir** instalado no sistema.

1. Clone o repositório:
   ```sh
   git clone https://github.com/seu-repositorio/telefonia.git
   cd telefonia
   ```
2. Instale as dependências:
   ```sh
   mix deps.get
   ```
3. Inicialize o sistema (criação dos arquivos TXT):
   ```elixir
   Telefonia.start()
   ```

## Como Usar

### Cadastrar um Assinante
```elixir
Telefonia.cadastrar_assinante("João", "12345", "111.222.333-44", :prepago)
```

### Listar Assinantes
```elixir
Telefonia.listar_assinantes()
```

### Realizar uma Chamada
```elixir
Telefonia.fazer_chamada("12345", :prepago, ~D[2025-03-01], 10)
```

### Realizar uma Recarga
```elixir
Telefonia.recarga("12345", ~D[2025-03-01], 50)
```

### Gerar Conta do Assinante
```elixir
Telefonia.imprimir_contas(3, 2025)
```

## Testes
O projeto possui um conjunto de testes automatizados.

Para rodar os testes, utilize:
```sh
mix test
```

Para rodar os testes com cobertura de código:
```sh
mix test --cover
```

## Documentação
A documentação completa do projeto está disponível e pode ser gerada com:
```sh
mix docs
```
Isso criará a documentação na pasta `docs`. Para acessá-la, abra o arquivo `docs/index.html` no navegador.

## Considerações Finais
Este projeto foi desenvolvido com **Elixir** e tem como objetivo demonstrar conceitos de manipulação de arquivos, estrutura modular e testes automatizados. Sinta-se à vontade para contribuir e melhorar o código!

