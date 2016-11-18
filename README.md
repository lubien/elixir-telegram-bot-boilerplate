# Elixir Telegram Bot Boilerplate

> A boilerplate for making bots for telegram using Elixir because of yes

## Getting Started

  1. Setup you bot name and telegram bot token at `config/config.ex`

  > You may set up environment-wide configurations at `dev.ex`, `prod.ex`
  > and `test` at the `config/` folder if you have different bots for different
  > environments

    ```elixir
    config :app,
      bot_name: "bot_user_name"

    config :nadia,
      token: "abcdefg_12345678910_the_game"
    ```

  2. Setup commands at `lib/app/commands.ex`

  3. Run at your shell

    ```sh
    λ mix
    ```

## See also

* [Rekyuu's version](https://github.com/rekyuu/elixir_telegram_bot).
I've based my bot mostly in his

## License

[MIT](LICENSE.md)

