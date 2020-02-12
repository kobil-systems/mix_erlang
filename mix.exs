defmodule MixErlang.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_erlang,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cf, ">= 0.0.0"},
      {:cth_readable, "~> 1.4.5"},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end
end
