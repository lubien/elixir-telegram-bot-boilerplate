defmodule App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(App.Poller, []),
      worker(App.Matcher, [])
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link children, opts
  end
end
