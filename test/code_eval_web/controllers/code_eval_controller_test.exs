defmodule CodeEvalWeb.CodeEvalControllerTest do
  use CodeEvalWeb.ConnCase

  describe "run/1" do
    test "evaluates code successfully", %{conn: conn} do
      code = "Enum.reduce([1, 2, 3], 0, &(&1 + &2))"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert json_response(response, 200) == %{"result" => 6}
    end

    test "returns an error for incorrect code", %{conn: conn} do
      code = "Enum.reduce([1, 2, 3], 0, &(&1 +/ &2))"
      params = %{code: code}

      response = post(conn, "/api/run", params)
      assert %{"error" => _error_message} = json_response(response, 200)
    end
  end
end
