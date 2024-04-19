defmodule DockerCompose.MixProject do
  use Mix.Project

  def project do
    [
      app: :docker_compose,
      version: "1.0.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
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
    [{:ex_doc, "~> 0.32.1", only: :dev, runtime: false}]
  end

  defp description do
    "Work with docker-compose definitions from Elixir."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/altworx/docker-compose-elixir"}
    ]
  end
end
