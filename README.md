# Docker Compose Elixir

Elixir library to work with Docker Compose.

It wraps around the [docker-compose CLI](https://github.com/docker/compose-cli) and provides subset
of the capabilities directly from Elixir.

## Installation

It's available in Hex, just add the snippet below to your dependencies.

```elixir
{:docker_compose, "~> 0.2"}
```

Documentation can be found at [HexDocs](https://hexdocs.pm/docker_compose).

Make sure you have the `docker-compose` executable available and working, this library is only a
wrapper around it. If running the app inside docker make sure the container has access to the docker
socket and that the `docker-compose` inside the docker container works fine.

## Using the library

The simplest and prob. most used command is `up` to start services defined in a compose definition.

```elixir
DockerCompose.up()
```

If the compose is not located in the standard location you can use `compose_path` parameter, there
are few other parameters for the most common scenarios, e.g. you can only start a specific services.

```elixir
DockerCompose.up(compose_path: "docker/my-compose.yml", service: "db", service: "kafka")
```

For the full list of commands and options check out the official documentation at
[HexDocs](https://hexdocs.pm/docker_compose_cli).

## Collaboration

If you found a bug or if you want some feature, feel free to open an issue or PR. We are open for
collaboration! The library is not 100% complete, it implements what was needed at the time. However,
it is very simple to add other options or commands, so feel free to open PRs.


