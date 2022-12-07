defmodule KinoSlack.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Slack integration with Livebook"

  def project do
    [
      app: :kino_slack,
      version: @version,
      description: @description,
      name: "KinoSlack",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [mod: {KinoSlack.Application, []}]
  end

  defp deps do
    [
      {:kino, "~> 0.7"},
      {:req, "~> 0.3"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "components",
      source_url: "https://github.com/livebook-dev/kino_slack",
      source_ref: "v#{@version}",
      extras: ["guides/components.livemd"]
    ]
  end

  def package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/livebook-dev/kino_slack"
      }
    ]
  end
end
