defmodule CodeEvalWeb.CodeEvalController do
  use CodeEvalWeb, :controller
  alias CodeEval.Evaluator
  alias CodeEval.Cache

  def run(conn, %{"code" => code}) do
    case Cache.fetch(code) do
      {:ok, {result, output}} ->
        send_json_response(conn, 200, %{result: result, output: output})

      _ ->
        task = Task.async(fn -> Evaluator.run(code) end)

        try do
          case Task.await(task, execution_timeout()) do
            {:ok, {result, output} = output_tuple} ->
              Cache.store(code, output_tuple)
              send_json_response(conn, 200, %{result: result, output: output})

            {:error, error} ->
              send_json_response(conn, 400, %{error: error})
          end
        catch
          :exit, _ ->
            Task.shutdown(task, :brutal_kill)
            send_json_response(conn, 408, %{error: "Execution timed out"})
        end
    end
  end

  defp execution_timeout, do: Application.fetch_env!(:code_eval, :execution_timeout)

  defp send_json_response(conn, status, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(payload))
  end
end
