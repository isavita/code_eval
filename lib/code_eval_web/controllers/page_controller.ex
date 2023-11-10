defmodule CodeEvalWeb.PageController do
  use CodeEvalWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def health(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
  end
end
