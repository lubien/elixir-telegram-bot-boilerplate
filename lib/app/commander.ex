defmodule App.Commander do
  @bot_name Application.get_env(:app, :bot_name)

  # Code injectors

  defmacro __using__(_opts) do
    quote do
      require Logger
      import App.Commander
      alias Nadia.Model
      alias Nadia.Model.InlineQueryResult

      def match_message(message) do
        try do
          apply __MODULE__, :do_match_message, [message]
        rescue
          err in FunctionClauseError ->
            Logger.log :warn, """
              Errored when matching command. #{Poison.encode! err}
              Message was: #{Poison.encode! message}
              """
        end
      end
    end
  end

  def generate_message_matcher(function) do
    quote do
      def do_match_message(var!(update)) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  defp generate_command(command, function) do
    quote do
      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command)
        }
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> " " <> _
        }
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> "@" <> unquote(@bot_name)
        }
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> "@" <> unquote(@bot_name) <> " " <> _
        }
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  def generate_inline_query_matcher(function) do
    quote do
      def do_match_message(%{inline_query: inline_query} = var!(update))
      when not is_nil(inline_query) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  def generate_inline_query_command(command, function) do
    quote do
      def do_match_message(%{
        inline_query: %{query: "/" <> unquote(command)}
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        inline_query: %{query: "/" <> unquote(command) <> " " <> _}
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  def generate_callback_query_matcher(function) do
    quote do
      def do_match_message(%{callback_query: callback_query} = var!(update))
      when not is_nil(callback_query) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  def generate_callback_query_command(command, function) do
    quote do
      def do_match_message(%{
        callback_query: %{data: "/" <> unquote(command)}
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        callback_query: %{data: "/" <> unquote(command) <> " " <> _}
      } = var!(update)) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  # Receiver Macros

  defmacro message(do: function) do
    generate_message_matcher(function)
  end

  defmacro command(command, do: function) do
    generate_command(command, function)
  end

  defmacro inline_query(do: function) do
    generate_inline_query_matcher(function)
  end

  defmacro inline_query_command(command, do: function) do
    generate_inline_query_command(command, function)
  end

  defmacro callback_query_command(command, do: function) do
    generate_callback_query_command(command, function)
  end

  defmacro callback_query(do: function) do
    generate_callback_query_matcher(function)
  end

  # Sender Macros

  defmacro answer_callback_query(options \\ []) do
    quote bind_quoted: [options: options] do
      Nadia.answer_callback_query var!(update).callback_query.id, options
    end
  end

  defmacro answer_inline_query(results, options \\ []) do
    quote bind_quoted: [results: results, options: options] do
      Nadia.answer_inline_query var!(update).inline_query.id, results, options
    end
  end

  defmacro send_audio(audio, options \\ []) do
    quote bind_quoted: [audio: audio, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_audio inline_query.from.id, audio, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_audio callback_query.message.chat.id, audio, options
        update ->
          Nadia.send_audio update.message.chat.id, audio, options
      end
    end
  end

  defmacro send_chat_action(action) do
    quote bind_quoted: [action: action] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_chat_action inline_query.from.id, action
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_chat_action callback_query.message.chat.id, action
        update ->
          Nadia.send_chat_action update.message.chat.id, action
      end
    end
  end

  defmacro send_contact(phone_number, first_name, options \\ []) do
    quote bind_quoted: [phone_number: phone_number, first_name: first_name,
                        options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_contact inline_query.from.id, phone_number, first_name,
                             options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_contact callback_query.message.chat.id, phone_number,
                             first_name, options
        update ->
          Nadia.send_contact update.message.chat.id, phone_number,
                             first_name, options
      end
    end
  end

  defmacro send_document(document, options \\ []) do
    quote bind_quoted: [document: document, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_document inline_query.from.id, document, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_document callback_query.message.chat.id, document, options
        update ->
          Nadia.send_document update.message.chat.id, document, options
      end
    end
  end

  defmacro send_location(latitude, longitude, options \\ []) do
    quote bind_quoted: [latitude: latitude, longitude: longitude,
                        options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_location inline_query.from.id, latitude, longitude, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_location callback_query.message.chat.id, latitude,
                              longitude, options
        update ->
          Nadia.send_location update.message.chat.id, latitude,
                              longitude, options
      end
    end
  end

  defmacro send_message(text, options \\ []) do
    quote bind_quoted: [text: text, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_message inline_query.from.id, text, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_message callback_query.message.chat.id, text, options
        update ->
          Nadia.send_message update.message.chat.id, text, options
      end
    end
  end

  defmacro send_photo(photo, options \\ []) do
    quote bind_quoted: [photo: photo, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_photo inline_query.from.id, photo, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_photo callback_query.message.chat.id, photo, options
        update ->
          Nadia.send_photo update.message.chat.id, photo, options
      end
    end
  end

  defmacro send_sticker(sticker, options \\ []) do
    quote bind_quoted: [sticker: sticker, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_sticker inline_query.from.id, sticker, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_sticker callback_query.message.chat.id, sticker, options
        update ->
          Nadia.send_sticker update.message.chat.id, sticker, options
      end
    end
  end

  defmacro send_venue(latitude, longitude, title, address, options \\ []) do
    quote bind_quoted: [latitude: latitude, longitude: longitude,
                        title: title, address: address, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_venue inline_query.from.id, latitude, longitude, title,
                           address, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_venue callback_query.message.chat.id, latitude, longitude,
                           title, address, options
        update ->
          Nadia.send_venue update.message.chat.id, latitude, longitude,
                           title, address, options
      end
    end
  end

  defmacro send_video(video, options \\ []) do
    quote bind_quoted: [video: video, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_video inline_query.from.id, video, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_video callback_query.message.chat.id, video, options
        update ->
          Nadia.send_video update.message.chat.id, video, options
      end
    end
  end

  defmacro send_voice(voice, options \\ []) do
    quote bind_quoted: [voice: voice, options: options] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.send_voice inline_query.from.id, voice, options
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.send_voice callback_query.message.chat.id, voice, options
        update ->
          Nadia.send_voice update.message.chat.id, voice, options
      end
    end
  end

  # Action Macros

  defmacro forward_message(chat_id) do
    quote bind_quoted: [chat_id: chat_id] do
      case var!(update) do
        # Inline querys are not messages
        # therefore no need to implement this
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.forward_message chat_id, callback_query.message.chat.id,
                                callback_query.message.message_id
        update ->
          Nadia.forward_message chat_id, update.message.chat.id,
                                update.message.message_id
      end
    end
  end

  defmacro get_chat do
    quote do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.get_chat inline_query.from.id
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.get_chat callback_query.message.chat.id
        update ->
          Nadia.get_chat update.message.chat.id
      end
    end
  end

  defmacro get_chat_administrators do
    quote do
      case var!(update) do
        # Inline querys resolves to the user private chat with this bot
        # therefore no need to implement this
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.get_chat_administrators callback_query.message.chat.id
        update ->
          Nadia.get_chat_administrators update.message.chat.id
      end
    end
  end

  defmacro get_chat_member(user_id) do
    quote bind_quoted: [user_id: user_id] do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          Nadia.get_chat_member inline_query.from.id, user_id
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.get_chat_member callback_query.message.chat.id, user_id
        update ->
          Nadia.get_chat_member update.message.chat.id, user_id
      end
    end
  end

  defmacro get_chat_members_count do
    quote do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          # Always 2 since it resolves to your chat with this bot
          {:ok, 2}
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.get_chat_members_count callback_query.message.chat.id
        update ->
          Nadia.get_chat_members_count update.message.chat.id
      end
    end
  end

  defmacro kick_chat_member(user_id) do
    quote bind_quoted: [user_id: user_id] do
      case var!(update) do
        # Inline querys resolves to the user private chat with this bot
        # therefore no need to implement this
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.kick_chat_member callback_query.message.chat.id, user_id
        update ->
          Nadia.kick_chat_member update.message.chat.id, user_id
      end
    end
  end

  defmacro leave_chat do
    quote do
      case var!(update) do
        # Inline querys resolves to the user private chat with this bot
        # therefore no need to implement this
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.leave_chat callback_query.message.chat.id
        update ->
          Nadia.leave_chat update.message.chat.id
      end
    end
  end

  defmacro unban_chat_member(user_id) do
    quote bind_quoted: [user_id: user_id] do
      case var!(update) do
        # Inline querys resolves to the user private chat with this bot
        # therefore no need to implement this
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          Nadia.unban_chat_member callback_query.message.chat.id, user_id
        update ->
          Nadia.unban_chat_member update.message.chat.id, user_id
      end
    end
  end
end
