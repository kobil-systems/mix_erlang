defmodule Mix.Tasks.Xeref do
  use Mix.Task

  def run(_args) do
    Mix.Task.run(:loadpaths)

    {:ok, pid} = :xref.start(xref_mode: :functions)

    IO.inspect :xref.analyze(pid, :deprecated_functions)
  end
end
