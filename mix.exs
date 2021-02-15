defmodule Seely.MixProject do
  use Mix.Project

  def project do
    [
      app: :seely,
      version: "0.1.0",
      description: description(),
      package: package(),
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: compiler_paths(Mix.env()),

      # Docs
      name: "Seely",
      source_url: "https://github.com/iboard/seely",
      homepage_url: "https://hexdocs.pm/seely",
      docs: [
        # The main page in the docs
        main: "readme",
        extras: ["LICENSE.md", "README.md"]
      ]
    ]
  end

  defp description() do
    "A CLI package for Elixir"
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/iboard/seely",
        "Hex" => "https://hexdocs.pm/seely"
      }
    ]
  end

  def compiler_paths(:test),
    do: ["test/helpers", "test/support"] ++ compiler_paths(:prod)

  def compiler_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Seely.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end
end
