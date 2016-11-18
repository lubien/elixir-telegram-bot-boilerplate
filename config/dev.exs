use Mix.Config

config :app,
  bot_name: "lubien_tests_bot"

config :nadia,
  token: System.get_env("GTI_BOT_TOKEN")
