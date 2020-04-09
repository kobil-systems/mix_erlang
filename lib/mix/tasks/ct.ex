defmodule Mix.Tasks.Ct do
  use Mix.Task

  @preferred_cli_env :test
  @recursive true

  @options [
    suite: [:string, :keep],
    group: [:string, :keep],
    testcase: [:string, :keep],
    dir: [:string, :keep],
    sys_config: [:string, :keep],
    cover: :boolean
  ]

  @cover [tool: Mix.Tasks.Test.Cover, output: "cover"]

  def run(args) do
    {opts, _, args} = OptionParser.parse(args, strict: @options, aliases: [c: :cover])
    project = Mix.Project.config()

    unless System.get_env("MIX_ENV") || Mix.env() == :test do
      Mix.raise(
        "\"mix ct\" is running in the \"#{Mix.env()}\" environment. " <>
          "If you are running tests alongside another task, please set MIX_ENV"
      )
    end

    options =
      if {:d, :TEST} in Mix.Project.config()[:erlc_options] do
        []
      else
        [d: :TEST]
      end

    :ok = Mix.Erlang.recompile_with_options(args, options)

    options =
      project
      |> Keyword.get(:ct_options, [])
      |> Keyword.put(:auto_compile, false)
      |> Keyword.put_new(:dirs, ["test"])
      |> Keyword.update(:logdir, 'log/ct', &to_erl_path/1)
      |> set_args(:suite, opts)
      |> set_args(:group, opts)
      |> set_args(:testcase, opts)
      |> Keyword.update!(:dirs, &(&1 ++ Keyword.get_values(opts, :dir)))

    File.mkdir_p!(options[:logdir])

    {:ok, suites} = compile_tests(options)

    cover =
      if opts[:cover] do
        compile_path = Mix.Project.compile_path(project)
        cover = Keyword.merge(@cover, project[:test_coverage] || [])
        cover[:tool].start(compile_path, cover)
      end

    case :ct.run_test(Keyword.put_new(options, :suite, suites)) do
      {ok, failed, {user_skipped, auto_skipped}} ->
        cover && cover.()

        Mix.shell().info("""
          Finished:
          #{ok} passed
          #{failed} failed
          #{user_skipped + auto_skipped} skipped
        """)

        if failed > 0 do
          System.at_exit(fn _ -> exit({:shutdown, 1}) end)
        end

        :ok

      {:error, reason} ->
        Mix.raise("Failed to run common test with reason: #{inspect(reason, pretty: true)}")
    end
  end

  defp set_args(options, key, args), do: set_args(options, key, args, key)

  defp set_args(options, okey, args, akey) do
    case Keyword.get_values(args, akey) do
      [] ->
        options

      values when is_list(values) ->
        Keyword.put(options, okey, Enum.map(values, &to_charlist/1))
    end
  end

  defp compile_tests(options) do
    dirs = Keyword.fetch!(options, :dirs)
    include_dir = to_erl_path(Mix.Project.config()[:erlc_include_path])

    erlc_opts = [:report, :binary, {:i, include_dir}] ++ Mix.Project.config()[:erlc_options]

    mods =
      for path <- dirs,
          file <- Path.wildcard("#{path}/**/*_SUITE.erl") do
        {:ok, mod, binary} = :compile.file(String.to_charlist(file), erlc_opts)

        {:module, ^mod} = :code.load_binary(mod, to_charlist(file), binary)

        mod
      end

    {:ok, mods}
  end

  defp to_erl_path(path) when is_binary(path), do: String.to_charlist(path)
  defp to_erl_path(path) when is_list(path), do: path
end
