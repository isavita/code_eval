defmodule CodeEval.EvaluatorTest do
  use ExUnit.Case
  alias CodeEval.Evaluator

  describe "Evaluator.run/1" do
    test "evaluates code successfully with allowed modules" do
      code = "Enum.sum([1, 2, 3])"
      assert {:ok, 6} == Evaluator.run(code)
    end

    test "returns an error for code with syntax errors" do
      code = "Enum.sum([1, 2, 3"

      assert {:error,
              "Error on line 1, column 18: missing terminator: ] (for \"[\" starting at line 1)"} =
               Evaluator.run(code)
    end
  end
end
