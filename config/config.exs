use Mix.Config

config :app,
  bot_name: ""

config :nadia,
  token: ""

import_config "#{Mix.env}.exs"
