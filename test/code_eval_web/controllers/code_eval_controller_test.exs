defmodule CodeEvalWeb.CodeEvalControllerTest do
  use CodeEvalWeb.ConnCase
  alias CodeEval.Cache

  @valid_auth_header Base.encode64("test_token")

  setup do
    original_group_leader = Process.group_leader()
    {:ok, capture_pid} = StringIO.open("")
    Process.group_leader(self(), capture_pid)
    Cache.reset!()

    on_exit(fn ->
      Process.group_leader(self(), original_group_leader)
    end)

    :ok
  end

  describe "run/1" do
    test "evaluates code successfully", %{conn: conn} do
      conn = put_req_header(conn, "x-api-key", @valid_auth_header)
      code = "Enum.reduce([1, 2, 3], 0, &(&1 + &2))"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert json_response(response, 200) == %{"result" => 6, "output" => ""}
    end

    test "captures IO output in code execution", %{conn: conn} do
      conn = put_req_header(conn, "x-api-key", @valid_auth_header)

      code = """
      result = Enum.sum([1, 2, 3])
      IO.puts("Sum: \#{result}")
      result
      """

      params = %{code: code}

      response = post(conn, "/api/run", params)

      assert json_response(response, 200) == %{
               "output" => "Sum: 6\n",
               "result" => 6
             }
    end

    test "returns an error for incorrect code", %{conn: conn} do
      conn = put_req_header(conn, "x-api-key", @valid_auth_header)
      code = "Enum.reduce([1, 2, 3], 0, &(&1 +/ &2))"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert %{"error" => _error_message} = json_response(response, 400)
    end

    test "authentication fails with incorrect token", %{conn: conn} do
      conn = put_req_header(conn, "x-api-key", Base.encode64("wrong_token"))
      code = "Enum.sum([1, 2, 3])"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert response.status == 401
    end

    test "authentication fails with wrongly encoded token", %{conn: conn} do
      conn = put_req_header(conn, "x-api-key", "Basic wrong_encoding")
      code = "Enum.sum([1, 2, 3])"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert response.status == 401
    end

    test "code execution times out", %{conn: conn} do
      old_timeout = Application.get_env(:code_eval, :execution_timeout)
      Application.put_env(:code_eval, :execution_timeout, 10)
      on_exit(fn -> Application.put_env(:code_eval, :execution_timeout, old_timeout) end)

      conn = put_req_header(conn, "x-api-key", @valid_auth_header)
      code = ":timer.sleep(100)"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert response.status == 408
      assert %{"error" => "Execution timed out"} = json_response(response, 408)
    end

    test "stores successful requests to the cache", %{conn: conn} do
      old_ttl = Application.get_env(:code_eval, :cachex)[:default_ttl]
      Application.put_env(:code_eval, :cachex, default_ttl: 10_000)
      Cache.reset!()

      on_exit(fn ->
        Application.put_env(:code_eval, :cachex, default_ttl: old_ttl)
        Cache.reset!()
      end)

      conn = put_req_header(conn, "x-api-key", @valid_auth_header)
      code = "Enum.reduce([1, 2, 3], 0, &(&1 + &2))"

      response = post(conn, "/api/run", %{code: code})
      response_body = json_response(response, 200)

      {:ok, cache_value} = Cache.fetch(code)
      assert cache_value == {response_body["result"], response_body["output"]}

      # make second request to verify the cache returns the same value
      response = post(conn, "/api/run", %{code: code})
      assert json_response(response, 200) == response_body
    end
  end
end
