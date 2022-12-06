defmodule KinoSlack.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Kino.SmartCell.register(KinoSlack.MessageCell)

    children = []
    opts = [strategy: :one_for_one, name: KinoSlack.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
