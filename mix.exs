defmodule Postfix.MixProject do
  use Mix.Project

  def project do
    [
      app: :postfix,
      deps: deps(),
      description: "Postfix evaluator",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: "1.1.336"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/devstopfix/postfix-elixir"}
    ]
  end

  def elixirc_paths(:test), do: ["test/helpers"] ++ elixirc_paths(:prod)
  def elixirc_paths(_), do: ["lib"]
end
