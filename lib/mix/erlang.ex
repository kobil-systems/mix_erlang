defmodule Mix.Erlang do
  def load_configs(paths) do
    for path <- paths,
        config = consult_config(path) do
      set_env(config)
    end

    :ok
  end

  defp set_env(config) do
    for {app, app_conf} <- config,
        {key, value} <- app_conf,
        do: Application.put_env(app, key, value, persistent: true)
  end

  defp consult_config(path) do
    case :file.consult(path) do
      {:ok, [terms]} ->
        consult_config_terms(terms)

      {:ok, []} ->
        []

      {:error, :enoent} ->
        []

      {:error, reason} ->
        raise "Error reading file #{path}:\n#{inspect(reason)}"
    end
  end

  defp consult_config_terms(config) do
    Enum.flat_map(config, fn
      sub_config when is_list(sub_config) ->
        case Path.extname(sub_config) do
          "config" -> consult_config(sub_config)
          _ -> consult_config(sub_config ++ '.config')
        end

      other ->
        [other]
    end)
  end
end
