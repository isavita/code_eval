defmodule CodeEval.Evaluator do
  def run(code) do
    try do
      case Code.compile_string(code) do
        [] ->
          evaluate(code)

        [{:ok, _module}] ->
          evaluate(code)

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

  defp evaluate(code) do
    try do
      {result, _binding} = Code.eval_string(code)
      {:ok, result}
    rescue
      e in [RuntimeError, ArgumentError] -> {:error, Exception.message(e)}
    end
  end

  defp format_token_error(line, column, description) do
    "Error on line #{line}, column #{column}: #{description}"
  end
end
