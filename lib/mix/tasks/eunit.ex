defmodule Mix.Tasks.Eunit do
  use Mix.Task

  @options [
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
      [{:d, :EUNIT}, {:d, :TEST}, :verbose] ++
        Keyword.get(Mix.Project.config(), :erlc_options, [])

    System.put_env("ERL_COMPILER_OPTIONS", List.to_string(:io_lib.format("~p", [options])))

    Mix.Project.compile(args)
    Mix.Task.run(:loadpaths)

    cover =
      if opts[:cover] do
        compile_path = Mix.Project.compile_path(project)
        cover = Keyword.merge(@cover, project[:test_coverage] || [])
        cover[:tool].start(compile_path, cover)
      end

    appname = Keyword.fetch!(project, :app)

    case :eunit.test(application: appname) do
      :ok ->
        cover && cover.()
        :ok
      :error -> Mix.raise("EUnit tests failed")
    end
  end
end
