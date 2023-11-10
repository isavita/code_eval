defmodule CodeEvalWeb.Plugs.Auth do
  import Plug.Conn

  @behaviour Plug

  def init(options), do: options

  def call(conn, _options) do
    auth_header = get_req_header(conn, "x-api-key")
    tokens = Application.fetch_env!(:code_eval, :auth_tokens)

    case auth_header do
      [creds] ->
        case decode_token(creds) do
          {:ok, user_token} ->
            if user_token in tokens do
              conn
            else
              send_unauthorized_response(conn)
            end

          _ ->
            send_unauthorized_response(conn)
        end

      _ ->
        send_unauthorized_response(conn)
    end
  end

  defp decode_token(token) do
    try do
      {:ok, Base.decode64!(token)}
    rescue
      _ -> :error
    end
  end

  defp send_unauthorized_response(conn) do
    conn
    |> send_resp(401, "Unauthorized")
    |> halt()
  end
end
