defmodule App.Mixfile do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.7",
      default_task: "server",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [extra_applications: [:logger, :nadia], mod: {App, []}]
  end

  defp deps do
    [
      {:nadia, "~> 0.7.0"},
      {:poison, "~> 3.1"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
    ]
  end

  defp aliases do
    [server: "run --no-halt"]
  end
end
