defmodule App.Router do
  @bot_name Application.get_env(:app, :bot_name)

  # Code injectors

  defmacro __using__(_opts) do
    quote do
      require Logger
      import App.Router

      def match_message(message) do
        try do
          apply(__MODULE__, :do_match_message, [message])
        rescue
          err in FunctionClauseError ->
            Logger.log(:warn, """
            Errored when matching command. #{Poison.encode!(err)}
            Message was: #{Poison.encode!(message)}
            """)
        end
      end
    end
  end

  def generate_message_matcher(handler) do
    quote do
      def do_match_message(var!(update)) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  defp generate_command(command, handler) do
    quote do
      def do_match_message(
            %{
              message: %{
                text: "/" <> unquote(command)
              }
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end

      def do_match_message(
            %{
              message: %{
                text: "/" <> unquote(command) <> " " <> _
              }
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end

      def do_match_message(
            %{
              message: %{
                text: "/" <> unquote(command) <> "@" <> unquote(@bot_name)
              }
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end

      def do_match_message(
            %{
              message: %{
                text: "/" <> unquote(command) <> "@" <> unquote(@bot_name) <> " " <> _
              }
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  def generate_inline_query_matcher(handler) do
    quote do
      def do_match_message(%{inline_query: inline_query} = var!(update))
          when not is_nil(inline_query) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  def generate_inline_query_command(command, handler) do
    quote do
      def do_match_message(
            %{
              inline_query: %{query: "/" <> unquote(command)}
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end

      def do_match_message(
            %{
              inline_query: %{query: "/" <> unquote(command) <> " " <> _}
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  def generate_callback_query_matcher(handler) do
    quote do
      def do_match_message(%{callback_query: callback_query} = var!(update))
          when not is_nil(callback_query) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  def generate_callback_query_command(command, handler) do
    quote do
      def do_match_message(
            %{
              callback_query: %{data: "/" <> unquote(command)}
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end

      def do_match_message(
            %{
              callback_query: %{data: "/" <> unquote(command) <> " " <> _}
            } = var!(update)
          ) do
        handle_message(unquote(handler), [var!(update)])
      end
    end
  end

  # Receiver Macros

  ## Match All

  defmacro message(do: function) do
    generate_message_matcher(function)
  end

  defmacro message(module, function) do
    generate_message_matcher({module, function})
  end

  ## Command

  defmacro command(commands, do: function)
           when is_list(commands) do
    Enum.map(commands, fn command ->
      generate_command(command, function)
    end)
  end

  defmacro command(command, do: function) do
    generate_command(command, function)
  end

  defmacro command(commands, module, function)
           when is_list(commands) do
    Enum.map(commands, fn command ->
      generate_command(command, {module, function})
    end)
  end

  defmacro command(command, module, function) do
    generate_command(command, {module, function})
  end

  ## Inline query

  defmacro inline_query(do: function) do
    generate_inline_query_matcher(function)
  end

  defmacro inline_query(module, function) do
    generate_inline_query_matcher({module, function})
  end

  defmacro inline_query_command(commands, do: function)
           when is_list(commands) do
    Enum.map(commands, fn item ->
      generate_inline_query_command(item, function)
    end)
  end

  defmacro inline_query_command(command, do: function) do
    generate_inline_query_command(command, function)
  end

  defmacro inline_query_command(commands, module, function)
           when is_list(commands) do
    Enum.map(commands, fn item ->
      generate_inline_query_command(item, {module, function})
    end)
  end

  defmacro inline_query_command(command, module, function) do
    generate_inline_query_command(command, {module, function})
  end

  ## Callback query

  defmacro callback_query(do: function) do
    generate_callback_query_matcher(function)
  end

  defmacro callback_query(module, function) do
    generate_callback_query_matcher({module, function})
  end

  defmacro callback_query_command(commands, do: function)
           when is_list(commands) do
    Enum.map(commands, fn item ->
      generate_callback_query_command(item, function)
    end)
  end

  defmacro callback_query_command(command, do: function) do
    generate_callback_query_command(command, function)
  end

  defmacro callback_query_command(commands, module, function)
           when is_list(commands) do
    Enum.map(commands, fn item ->
      generate_callback_query_command(item, {module, function})
    end)
  end

  defmacro callback_query_command(command, module, function) do
    generate_callback_query_command(command, {module, function})
  end

  # Helpers

  def handle_message({module, function}, update)
      when is_atom(function) and is_list(update) do
    Task.start(fn ->
      apply(module, function, [hd(update)])
    end)
  end

  def handle_message({module, function}, update)
      when is_atom(function) do
    Task.start(fn ->
      apply(module, function, [update])
    end)
  end

  def handle_message(function, update)
      when is_function(function) do
    Task.start(fn ->
      function.()
    end)
  end

  def handle_message(_, _), do: nil
end
