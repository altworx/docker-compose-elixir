defmodule DockerCompose do
  @moduledoc """
  Docker Compose CLI

  Uses `docker-compose` executable, it must be installed and working.
  """

  @type up_summary :: %{
          created_containers: [String.t()],
          created_networks: [String.t()],
          pulled_images: [%{service: String.t(), image: String.t()}],
          removed_orphan_containers: [String.t()]
        }

  @type down_summary :: %{
          stopped_containers: [String.t()],
          removed_containers: [String.t()],
          removed_networks: [String.t()],
          removed_orphan_containers: [String.t()]
        }

  @type restart_summary :: %{restarted_containers: [String.t()]}
  @type start_summary :: %{restarted_services: [String.t()]}
  @type stop_summary :: %{stopped_services: [String.t()]}

  @doc """
  docker-compose up

  The command is executed in detached mode, result is returned after the whole command finishes,
  which might take a while if the images need to be pulled.

  ## Options
    - `compose_path: path` - path to the compose if not in the standard location
    - `force_recreate: true` - if true all specified services are forcefully recreated
    - `remove_orphans: true` - if true orphaned containers are removed
    - `service: name` - name of the service that should be started, can be specified multiple times
      to start multiple services. If it's not specified at all then all services are started.

  ## Result

  The function returns either `{:ok, summary}` if the request is successful or `{:error, exit_code,
  summary}`. The exit code is the exit code of the docker-compose process that failed.

  Summary is a map with
    - `created_containers` - which containers were created
    - `created_networks` - which networks were created
    - `pulled_images` - which images were pulled for which services
    - `removed_orphan_containers` - which containers were removed if `remove_orphans: true` is
      specified
  """
  @spec up(Keyword.t()) :: {:ok, up_summary()} | {:error, integer(), up_summary()}
  def up(opts) do
    args =
      [
        compose_opts(opts),
        "up",
        up_opts(opts),
        ["-d", "--no-color" | service_opts(opts)]
      ]
      |> List.flatten()

    args
    |> execute(opts)
    |> up_result()
  end

  @doc """
  docker-compose down

  ## Options
    - `compose_path: path` - path to the compose if not in the standard location
    - `remove_orphans: true` - if true orphaned containers are removed

  ## Result

  The function returns either `{:ok, summary}` if the request is successful or `{:error, exit_code,
  summary}`. The exit code is the exit code of the docker-compose process that failed.

  Summary is a map with
    - `stopped_containers` - which containers were stopped
    - `removed_containers` - which containers were removed
    - `removed_networks` - which networks were removed
    - `removed_orphan_containers` - which containers were removed if `remove_orphans: true` is
      specified
  """
  @spec down(Keyword.t()) :: {:ok, down_summary()} | {:error, integer(), down_summary()}
  def down(opts) do
    args =
      [
        compose_opts(opts),
        "down",
        down_opts(opts)
      ]
      |> List.flatten()

    args
    |> execute(opts)
    |> down_result()
  end

  # OPTS
  # - service - optional, by default all
  @doc """
  docker-compose restart

  ## Options
    - `compose_path: path` - path to the compose if not in the standard location
    - `service: name` - name of the service to be restarted, can be specified multiple times to
      restart multiple services at once. If not specified at all then all services are restarted.

  ## Result

  The function returns either `{:ok, summary}` if the request is successful or `{:error, exit_code,
  summary}`. The exit code is the exit code of the docker-compose process that failed.

  Summary is a map with
    - `restarted_containers` - which containers were restarted
  """
  @spec restart(Keyword.t()) :: {:ok, restart_summary()} | {:error, integer(), restart_summary()}
  def restart(opts) do
    args =
      [
        compose_opts(opts),
        "restart",
        service_opts(opts)
      ]
      |> List.flatten()

    args
    |> execute(opts)
    |> restart_result()
  end

  @doc """
  docker-compose stop

  ## Options
    - `compose_path: path` - path to the compose if not in the standard location
    - `service: name` - name of the service to be stopped, can be specified multiple times to stop
      multiple services at once. If not specified at all then all services are stopped.

  ## Result

  The function returns either `{:ok, summary}` if the request is successful or `{:error, exit_code,
  summary}`. The exit code is the exit code of the docker-compose process that failed.

  Summary is a map with
    - `stopped_services` - which services were stopped
  """
  @spec stop(Keyword.t()) :: {:ok, stop_summary()} | {:error, integer(), stop_summary()}
  def stop(opts) do
    args =
      [
        compose_opts(opts),
        "stop",
        service_opts(opts)
      ]
      |> List.flatten()

    args
    |> execute(opts)
    |> stop_result()
  end

  @doc """
  docker-compose start

  Note this can only be used to start previously created and stopped services. If you want to create
  and start the services use `up/1`.

  ## Options
    - `compose_path: path` - path to the compose if not in the standard location
    - `service: name` - name of the service to be started, can be specified multiple times to start
      multiple services at once. If not specified at all then all services are started.

  ## Result

  The function returns either `{:ok, summary}` if the request is successful or `{:error, exit_code,
  summary}`. The exit code is the exit code of the docker-compose process that failed.

  Summary is a map with
    - `started_services` - which services were started
  """
  @spec start(Keyword.t()) :: {:ok, start_summary()} | {:error, integer(), start_summary()}
  def start(opts) do
    args =
      [
        compose_opts(opts),
        "start",
        service_opts(opts)
      ]
      |> List.flatten()

    args
    |> execute(opts)
    |> start_result()
  end

  defp execute(args, opts) do
    System.cmd("docker-compose", args, [{:stderr_to_stdout, true} | cmd_opts(opts)])
  end

  defp compose_opts([{:compose_path, path} | rest]) do
    ["-f", Path.basename(path) | compose_opts(rest)]
  end

  defp compose_opts([_ | rest]), do: compose_opts(rest)
  defp compose_opts([]), do: []

  defp up_opts(opts) do
    opts
    |> Keyword.take([:force_recreate, :remove_orphans])
    |> command_opts()
  end

  defp down_opts(opts) do
    opts
    |> Keyword.take([:remove_orphans])
    |> command_opts()
  end

  defp command_opts([{:force_recreate, true} | rest]),
    do: ["--force-recreate" | command_opts(rest)]

  defp command_opts([{:remove_orphans, true} | rest]),
    do: ["--remove-orphans" | command_opts(rest)]

  defp command_opts([_ | rest]), do: command_opts(rest)
  defp command_opts([]), do: []

  defp service_opts([{:service, name} | rest]), do: [name | service_opts(rest)]
  defp service_opts([_ | rest]), do: service_opts(rest)
  defp service_opts([]), do: []

  defp cmd_opts([{:compose_path, path} | rest]) do
    [{:cd, Path.dirname(path)} | cmd_opts(rest)]
  end

  defp cmd_opts([_ | rest]), do: cmd_opts(rest)
  defp cmd_opts([]), do: []

  defp up_result({logs, exit_code}) do
    res(summarize_up_result(logs), exit_code)
  end

  defp summarize_up_result(logs) do
    created =
      Regex.scan(~r/Creating (\w+) ... done/, logs, capture: :all_but_first)
      |> List.flatten()

    created_networks =
      Regex.scan(~r/Creating network "([^"]+)"/, logs, capture: :all_but_first)
      |> List.flatten()

    pulled_images =
      Regex.scan(~r/Pulling (\w+) \(([^\)]+)\)/, logs, capture: :all_but_first)
      |> Enum.map(fn [service, image] -> %{service: service, image: image} end)

    removed_orphans =
      Regex.scan(~r/Removing orphan container "([^"]+)"/, logs, capture: :all_but_first)
      |> List.flatten()

    %{
      created_containers: created,
      created_networks: created_networks,
      pulled_images: pulled_images,
      removed_orphan_containers: removed_orphans
    }
  end

  defp down_result({logs, exit_code}) do
    res(summarize_down_result(logs), exit_code)
  end

  defp summarize_down_result(logs) do
    stopped =
      Regex.scan(~r/Stopping (\w+) ... done/, logs, capture: :all_but_first)
      |> List.flatten()

    removed =
      Regex.scan(~r/Removing (\w+) ... done/, logs, capture: :all_but_first)
      |> List.flatten()

    removed_networks =
      Regex.scan(~r/Removing network (\w+)/, logs, capture: :all_but_first)
      |> List.flatten()

    removed_orphans =
      Regex.scan(~r/Removing orphan container "([^"]+)"/, logs, capture: :all_but_first)
      |> List.flatten()

    %{
      stopped_containers: stopped,
      removed_containers: removed,
      removed_networks: removed_networks,
      removed_orphan_containers: removed_orphans
    }
  end

  defp restart_result({logs, exit_code}) do
    res(summarize_restart_result(logs), exit_code)
  end

  defp summarize_restart_result(logs) do
    restarted =
      Regex.scan(~r/Restarting (\w+) ... done/, logs, capture: :all_but_first)
      |> List.flatten()

    %{restarted_containers: restarted}
  end

  defp stop_result({logs, exit_code}) do
    res(summarize_stop_result(logs), exit_code)
  end

  defp summarize_stop_result(logs) do
    restarted =
      Regex.scan(~r/Stopping (\w+) ... done/, logs, capture: :all_but_first)
      |> List.flatten()

    %{stopped_containers: restarted}
  end

  defp start_result({logs, exit_code}) do
    res(summarize_start_result(logs), exit_code)
  end

  defp summarize_start_result(logs) do
    restarted =
      Regex.scan(~r/Starting (\w+) ... done/, logs, capture: :all_but_first)
      |> List.flatten()

    %{started_services: restarted}
  end

  defp res(summary, exit_code) do
    if exit_code == 0 do
      {:ok, summary}
    else
      {:error, exit_code, summary}
    end
  end
end
