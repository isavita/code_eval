defmodule CodeEval.Evaluator do
  def run(code) do
    try do
      case Code.compile_string(code) do
        [] ->
          capture_io(code)

        [{:ok, _module}] ->
          capture_io(code)

        _ ->
          {:error, "Compilation failed"}
      end
    catch
      :error, %TokenMissingError{line: line, description: description, column: column} ->
        {:error, format_token_error(line, column, description)}

      :error, _ ->
        {:error, "Syntax error or invalid code"}
    end
  end

  defp capture_io(code) do
    old_group_leader = Process.group_leader()
    {:ok, capture_pid} = StringIO.open("")
    Process.group_leader(self(), capture_pid)

    try do
      {result, _binding} = Code.eval_string(code)
      captured_output = capture_output(capture_pid)
      {:ok, {result, captured_output}}
    rescue
      e in [RuntimeError, ArgumentError] -> {:error, Exception.message(e)}
    after
      Process.group_leader(self(), old_group_leader)
    end
  end

  defp capture_output(pid) do
    StringIO.flush(pid)
  end

  defp format_token_error(line, column, description) do
    "Error on line #{line}, column #{column}: #{description}"
  end
end
