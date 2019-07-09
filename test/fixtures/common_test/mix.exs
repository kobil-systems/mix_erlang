defmodule Eunit.MixProject do
  use Mix.Project

  def project do
    [
      app: :common_test_fixture,
      version: "0.1.0",
      deps: deps(),
      deps_path: "../../../deps",
      build_path: "../../../_build",
      lockfile: "../../../mix.lock",
      preferred_cli_env: [
        ct: :test,
        eunit: :test
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_erlang, path: "../../.."}
    ]
  end
end
