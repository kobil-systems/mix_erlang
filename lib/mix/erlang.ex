defmodule Mix.Erlang do
  def recompile_with_options(args, opts) do
    System.put_env("ERL_COMPILER_OPTIONS", List.to_string(:io_lib.format("~w", [opts])))

    Mix.Task.rerun("compile", args)
    Mix.Task.rerun("loadpaths", args)

    Logger.App.stop()
    {:ok, _} = Application.ensure_all_started(:logger)

    :ok
  end
end
