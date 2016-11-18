defmodule App.Commander do
  @bot_name Application.get_env(:app, :bot_name)

  # Code injectors

  defmacro __using__(_opts) do
    quote do
      require Logger
      import App.Commander

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
      def do_match_message(var!(message)) do
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
      } = var!(message)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> " " <> _
        }
      } = var!(message)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> "@" <> unquote(@bot_name)
        }
      } = var!(message)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        message: %{
          text: "/" <> unquote(command) <> "@" <> unquote(@bot_name) <> " " <> _
        }
      } = var!(message)) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  def generate_inline_query_matcher(function) do
    quote do
      def do_match_message(%{inline_query: inline_query} = var!(message))
      when not is_nil(inline_query) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  def generate_inline_query_command(command, function) do
    quote do
      def do_match_message(%{
        inline_query: %{query: "/" <> unquote(command)}
      } = var!(message)) do
        Task.async fn -> unquote(function) end
      end

      def do_match_message(%{
        inline_query: %{query: "/" <> unquote(command) <> " " <> _}
      } = var!(message)) do
        Task.async fn -> unquote(function) end
      end
    end
  end

  # Macros

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
end
