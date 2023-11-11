defmodule CodeEval.EvaluatorTest do
  use ExUnit.Case
  alias CodeEval.Evaluator

  setup do
    original_group_leader = Process.group_leader()
    {:ok, capture_pid} = StringIO.open("")
    Process.group_leader(self(), capture_pid)

    on_exit(fn ->
      Process.group_leader(self(), original_group_leader)
    end)

    :ok
  end

  describe "Evaluator.run/1" do
    test "evaluates code successfully with allowed modules" do
      code = "Enum.sum([1, 2, 3])"
      assert {:ok, {6, ""}} == Evaluator.run(code)
    end

    test "returns an error for code with syntax errors" do
      code = "Enum.sum([1, 2, 3"

      assert {:error,
              "Error on line 1, column 18: missing terminator: ] (for \"[\" starting at line 1)"} =
               Evaluator.run(code)
    end

    test "captures IO output" do
      code = """
      result = 2 + 2
      IO.puts("Result: \#{result}")
      result
      """

      assert {:ok, {4, "Result: 4\n"}} == Evaluator.run(code)
    end
  end
end
