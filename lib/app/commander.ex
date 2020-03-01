defmodule App.Commander do
  @bot_name Application.get_env(:app, :bot_name)

  # Code injectors

  defmacro __using__(_opts) do
    quote do
      require Logger
      import App.Commander
      alias Nadia.Model
      alias Nadia.Model.InlineQueryResult
    end
  end

  # Sender Macros

  defmacro answer_callback_query(options \\ []) do
    quote bind_quoted: [options: options] do
      Nadia.answer_callback_query(var!(update).callback_query.id, options)
    end
  end

  defmacro answer_inline_query(results, options \\ []) do
    quote bind_quoted: [results: results, options: options] do
      Nadia.answer_inline_query(var!(update).inline_query.id, results, options)
    end
  end

  defmacro send_audio(audio, options \\ []) do
    quote bind_quoted: [audio: audio, options: options] do
      Nadia.send_audio(get_chat_id(), audio, options)
    end
  end

  defmacro send_chat_action(action) do
    quote bind_quoted: [action: action] do
      Nadia.send_chat_action(get_chat_id(), action)
    end
  end

  defmacro send_contact(phone_number, first_name, options \\ []) do
    quote bind_quoted: [phone_number: phone_number, first_name: first_name, options: options] do
      Nadia.send_contact(get_chat_id(), phone_number, first_name, options)
    end
  end

  defmacro send_document(document, options \\ []) do
    quote bind_quoted: [document: document, options: options] do
      Nadia.send_document(get_chat_id(), document, options)
    end
  end

  defmacro send_location(latitude, longitude, options \\ []) do
    quote bind_quoted: [latitude: latitude, longitude: longitude, options: options] do
      Nadia.send_location(get_chat_id(), latitude, longitude, options)
    end
  end

  defmacro send_message(text, options \\ []) do
    quote bind_quoted: [text: text, options: options] do
      Nadia.send_message(get_chat_id(), text, options)
    end
  end

  defmacro send_photo(photo, options \\ []) do
    quote bind_quoted: [photo: photo, options: options] do
      Nadia.send_photo(get_chat_id(), photo, options)
    end
  end

  defmacro send_sticker(sticker, options \\ []) do
    quote bind_quoted: [sticker: sticker, options: options] do
      Nadia.send_sticker(get_chat_id(), sticker, options)
    end
  end

  defmacro send_venue(latitude, longitude, title, address, options \\ []) do
    quote bind_quoted: [
            latitude: latitude,
            longitude: longitude,
            title: title,
            address: address,
            options: options
          ] do
      Nadia.send_venue(get_chat_id(), latitude, longitude, title, address, options)
    end
  end

  defmacro send_video(video, options \\ []) do
    quote bind_quoted: [video: video, options: options] do
      Nadia.send_video(get_chat_id(), video, options)
    end
  end

  defmacro send_voice(voice, options \\ []) do
    quote bind_quoted: [voice: voice, options: options] do
      Nadia.send_voice(get_chat_id(), voice, options)
    end
  end

  # Action Macros

  defmacro forward_message(chat_id) do
    quote bind_quoted: [chat_id: chat_id] do
      Nadia.forward_message(chat_id, get_chat_id(), var!(update).message.message_id)
    end
  end

  defmacro get_chat do
    quote do
      Nadia.get_chat(get_chat_id())
    end
  end

  defmacro get_chat_administrators do
    quote do
      Nadia.get_chat_administrators(get_chat_id())
    end
  end

  defmacro get_chat_member(user_id) do
    quote bind_quoted: [user_id: user_id] do
      Nadia.get_chat_member(get_chat_id(), user_id)
    end
  end

  defmacro get_chat_members_count do
    quote do
      Nadia.get_chat_members_count(get_chat_id())
    end
  end

  defmacro kick_chat_member(user_id) do
    quote bind_quoted: [user_id: user_id] do
      Nadia.kick_chat_member(get_chat_id(), user_id)
    end
  end

  defmacro leave_chat do
    quote do
      Nadia.leave_chat(get_chat_id())
    end
  end

  defmacro unban_chat_member(user_id) do
    quote bind_quoted: [user_id: user_id] do
      Nadia.unban_chat_member(get_chat_id(), user_id)
    end
  end

  # Helpers

  defmacro get_chat_id do
    quote do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          inline_query.from.id

        %{callback_query: callback_query} when not is_nil(callback_query) ->
          callback_query.message.chat.id

        %{message: %{chat: %{id: id}}} when not is_nil(id) ->
          id

        %{edited_message: %{chat: %{id: id}}} when not is_nil(id) ->
          id

        %{channel_post: %{chat: %{id: id}}} when not is_nil(id) ->
          id

        _ ->
          raise "No chat id found!"
      end
    end
  end
end
