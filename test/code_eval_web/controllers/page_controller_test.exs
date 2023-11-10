defmodule CodeEvalWeb.PageControllerTest do
  use CodeEvalWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Elixir Code Evaluation API"
  end

  test "GET /privacy", %{conn: conn} do
    conn = get(conn, ~p"/privacy")
    assert html_response(conn, 200) =~ "Privacy Policy"
  end

  test "GET /health", %{conn: conn} do
    conn = get(conn, ~p"/health")
    assert text_response(conn, 200) == "OK"
  end
end
