defmodule Mix.Tasks.Ct do
  use Mix.Task

  @preferred_cli_env :test

  def run(_args) do
    unless System.get_env("MIX_ENV") || Mix.env() == :test do
      Mix.raise("\"mix ct\" is running in the \"#{Mix.env()}\" environment. " <>
        "If you are running tests alongside another task, please set MIX_ENV")
    end

    Mix.Task.run(:compile)
    Mix.Task.run(:loadpaths)

    options =
      Mix.Project.config()
      |> Keyword.get(:ct_options, [])
      |> Keyword.put(:auto_compile, false)
      |> Keyword.put_new(:dirs, ["test"])
      |> Keyword.put_new(:logdir, 'log/ct')

    File.mkdir_p!(options[:logdir])

    {:ok, ebin} = compile_tests(options)

    case :ct.run_test(Keyword.put(options, :dir, [ebin])) do
      {_, 0, _} ->
        :ok

      {_, n, _} when n > 0 ->
        Mix.raise("Common test suite failed")

      {:error, reason} ->
        Mix.raise("Failed to run common test with reason: #{inspect(reason)}")
    end
  end

  defp compile_tests(options) do
    dirs = Keyword.fetch!(options, :dirs)

    ebin = Path.join(Mix.Project.app_path(), "common_test") |> to_charlist()

    File.mkdir_p!(ebin)

    for path <- dirs,
      file <- Path.wildcard("#{path}/**/*_SUITE.erl")
    do
      {:ok, _} = :compile.file(String.to_charlist(file), [:report, outdir: ebin])
    end

    {:ok, ebin}
  end
end
