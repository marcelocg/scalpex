defmodule Issues.Mixfile do
  use Mix.Project

  def project do
    [
      app: :scalpex,
      escript: escript_config(),
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # mod: { Scalpex.Application, [] },
      env: [ env: Mix.env ],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.0"},
      {:poison, "~> 3.1"},
      {:excoveralls, "~> 0.8", only: :test},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
  defp escript_config do
    [ main_module: Scalpex ]
  end
end
