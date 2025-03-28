defmodule Telefonia.MixProject do
  use Mix.Project

  def project do
    [
      app: :telefonia,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29.0", only: [:dev], runtime: false},
      {:earmark_parser, "~> 1.4.19", only: [:dev]},
      {:makeup_elixir, "~> 0.14", only: [:dev]},
      {:makeup_erlang, "~> 0.1", only: [:dev]},
      {:makeup_html, ">= 0.0.0", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
