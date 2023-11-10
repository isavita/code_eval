defmodule CodeEvalWeb.CodeEvalControllerTest do
  use CodeEvalWeb.ConnCase

  @valid_auth_header "Basic #{Base.encode64("test_token")}"

  describe "run/1" do
    test "evaluates code successfully", %{conn: conn} do
      conn = put_req_header(conn, "authorization", @valid_auth_header)
      code = "Enum.reduce([1, 2, 3], 0, &(&1 + &2))"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert json_response(response, 200) == %{"result" => 6}
    end

    test "returns an error for incorrect code", %{conn: conn} do
      conn = put_req_header(conn, "authorization", @valid_auth_header)
      code = "Enum.reduce([1, 2, 3], 0, &(&1 +/ &2))"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert %{"error" => _error_message} = json_response(response, 200)
    end

    test "authentication fails with incorrect token", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Basic #{Base.encode64("wrong_token")}")
      code = "Enum.sum([1, 2, 3])"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert response.status == 401
    end

    test "authentication fails with wrongly encoded token", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Basic wrong_encoding")
      code = "Enum.sum([1, 2, 3])"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert response.status == 401
    end
  end
end