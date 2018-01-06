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

## Macros

```elixir
command "foo" do
    IO.inspect update
    send_message "Hello Telegram"
end
```

The `command/2` macro take a string and a block. In this case, it'll try to match
anything that starts with `/foo`. Once it matches, it'll inject a constant named
`update` at the scope of the `do` block.

`send_message/2` is a macro that takes a string and a keyword list of options.
But, in fact, `send_message/2` maps to [Nadia.send_message/3](https://hexdocs.pm/nadia/Nadia.html#send_message/3)
a function that takes a chat ID as the first parameter.

The `send_message/2` macro automatically understands the local scoped `update`
constant and properly injects the chat ID for you so you can focus on sending stuff.
Most of the methods at Nadia module have it's macro version for you. Take a look at
[App.Commander](lib/app/commander.ex) to understand better.

Another feature that must be mentioned is that these macros can understand context.
Let's take a look at the `get_chat_id/2` definitions:

```elixir
  defmacro get_chat_id do
    quote do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          inline_query.from.id
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          callback_query.message.chat.id
        update ->
          update.message.chat.id
      end
    end
  end
```

If you ever used telegram bot API you may have experienced issues trying to find
where is the chat ID for the current update. That's solves it under the hood in
this boilerplate for you. Read more about it at [App.Commands](lib/app/commands.ex).

### Matcher macros

```elixir
# matches "/foo" commands
command "foo" do
end
```

```elixir
# matches "/foo" commands from callback querys
callback_query_command "foo" do
end
```

```elixir
# matches "/foo" commands from inline querys
inline_query_command "foo" do
end
```

```elixir
# fallback for callback querys
callback_query do
end
```

```elixir
# fallback for inline querys
inline_query do
end
```

```elixir
# fallback for all updates
# must be at the end of the file
message do
end
```
### Sender macros

```elixir
answer_callback_query(options \\ [])
```

```elixir
answer_inline_query(results, options \\ [])
```

```elixir
send_audio(audio, options \\ [])
```

```elixir
send_chat_action(action)
```

```elixir
send_contact(phone_number, first_name, options \\ [])
```

```elixir
send_document(document, options \\ [])
```

```elixir
send_location(latitude, longitude, options \\ [])
```

```elixir
send_message(text, options \\ [])
```

```elixir
send_photo(photo, options \\ [])
```

```elixir
send_sticker(sticker, options \\ [])
```

```elixir
send_venue(latitude, longitude, title, address, options \\ [])
```

```elixir
send_videos(video, options \\ [])
```

```elixir
send_voice(voice, options \\ [])
```

### Action macros

```elixir
# except for inline querys
forward_message(chat_id)
```

```elixir
get_chat
```

```elixir
# except for inline querys
get_chat_admnistrators
```

```elixir
get_chat_member(user_id)
```

```elixir
get_chat_member_count
```

```elixir
# except for inline querys
kick_chat_member(user_id)
```

```elixir
# except for inline querys
leave_chat
```

```elixir
# except for inline querys
unban_chat_member
```

```elixir
get_chat_id
```

## See also

* [Rekyuu's version](https://github.com/rekyuu/elixir_telegram_bot).
I've based my bot mostly in his

## License

[MIT](LICENSE.md)
