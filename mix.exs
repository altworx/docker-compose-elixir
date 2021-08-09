defmodule DockerCompose.MixProject do
  use Mix.Project

  def project do
    [
      app: :docker_compose,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "DockerCompose Elixir",
      source_url: "https://github.com/altworx/docker-compose-elixir",
      homepage_url: "https://github.com/altworx/docker-compose-elixir",
      docs: [
        main: "DockerCompose",
        api_reference: false
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ex_doc, "~> 0.25.1", only: :dev, runtime: false}]
  end
end
