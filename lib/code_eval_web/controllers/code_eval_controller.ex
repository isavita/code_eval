defmodule CodeEvalWeb.CodeEvalController do
  use CodeEvalWeb, :controller
  alias CodeEval.Evaluator

  def run(conn, %{"code" => code}) do
    case Evaluator.run(code) do
      {:ok, result} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{result: result}))

      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{error: error}))
    end
  end
end
