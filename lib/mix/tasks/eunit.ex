defmodule Mix.Tasks.Eunit do
  use Mix.Task

  def run(_args) do
    unless System.get_env("MIX_ENV") || Mix.env() == :test do
      Mix.raise(
        "\"mix ct\" is running in the \"#{Mix.env()}\" environment. " <>
          "If you are running tests alongside another task, please set MIX_ENV"
      )
    end

    recompile()

    appname = Keyword.fetch!(Mix.Project.config(), :app)
    :ok = Application.load(appname)

    case :eunit.test({:application, appname}) do
      :ok -> :ok
      :error -> Mix.raise("EUnit tests failed")
    end
  end

  defp recompile do
    options =
      [{:d, :EUNIT}, {:d, :TEST}, :verbose] ++
        Keyword.get(Mix.Project.config(), :erlc_options, [])

    System.put_env("ERL_COMPILER_OPTIONS", List.to_string(:io_lib.format("~p", [options])))

    Mix.Task.run("compile")
  end
end
