defmodule App.Commands do
  use App.Commander

  command "foo" do
    IO.puts "Activated /foo command"

    debug_message message
  end

  inline_query_command "foo" do
    IO.puts "Activated /foo command via inline query"

    debug_message message
  end

  inline_query do
    IO.puts "Activated the fallback for inline query"

    debug_message message
  end

  message do
    IO.puts "Activated the fallback for commands"

    debug_message message
  end

  defp debug_message(message) do
    message
    |> Poison.encode!
    |> IO.puts
  end
end
