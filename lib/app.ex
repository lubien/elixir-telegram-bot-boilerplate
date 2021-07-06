defmodule App do
  use Application

  def start(_type, _args) do
    bot_name = Application.get_env(:app, :bot_name)

    unless String.valid?(bot_name) do
      IO.warn("""
      Env not found Application.get_env(:app, :bot_name)
      This will give issues when generating commands
      """)
    end

    if bot_name == "" do
      IO.warn("An empty bot_name env will make '/anycommand@' valid")
    end

    import Supervisor.Spec, warn: false

    children = [
      %{
        id: App.Poller,
        start: {App.Poller, :start_link, []}
      },
      %{
        id: App.Matcher,
        start: {App.Matcher, :start_link, []}
      },
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_bot_name, do: Application.get_env(:app, :bot_name)
end
