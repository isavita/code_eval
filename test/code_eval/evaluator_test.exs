defmodule CodeEval.EvaluatorTest do
  use ExUnit.Case
  alias CodeEval.Evaluator

  import Mock

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

    test "evaluates Hundred Prisoners Problem strategies" do
      code = ~S"""
      defmodule HundredPrisoners do
        def optimal_room(_, _, _, []), do: []
        def optimal_room(prisoner, current_room, rooms, [_ | tail]) do
          found = Enum.at(rooms, current_room - 1) == prisoner
          next_room = Enum.at(rooms, current_room - 1)
          [found] ++ optimal_room(prisoner, next_room, rooms, tail)
        end

        def optimal_search(prisoner, rooms) do
          Enum.any?(optimal_room(prisoner, prisoner, rooms, Enum.to_list(1..50)))
        end
      end

      prisoners = 1..10
      n = 1..1000
      generate_rooms = fn -> Enum.shuffle(1..100) end

      random_strategy = Enum.count(n,
        fn _ ->
        rooms = generate_rooms.()
        Enum.all?(prisoners, fn pr -> pr in (rooms |> Enum.take_random(50)) end)
      end)

      optimal_strategy = Enum.count(n,
        fn _ ->
        rooms = generate_rooms.()
        Enum.all?(prisoners,
          fn pr -> HundredPrisoners.optimal_search(pr, rooms) end)
      end)

      IO.puts "Random strategy: #{random_strategy} / #{n |> Range.size}"
      IO.puts "Optimal strategy: #{optimal_strategy} / #{n |> Range.size}"
      {random_strategy, optimal_strategy, n |> Range.size}
      """

      assert {:ok, {{random_strategy, optimal_strategy, _total_runs}, "Random strategy:" <> _}} =
               Evaluator.run(code)

      # We expect the optimal strategy to be better than the random strategy.
      assert optimal_strategy > random_strategy
    end

    test "executes HTTP request and checks for HTML content" do
      with_mock HTTPoison, get!: fn _url -> %{body: "<html></html>"} end do
        code = "HTTPoison.get!(\"https://example.com/\").body"
        assert {:ok, {result, ""}} = Evaluator.run(code)
        assert result == "<html></html>"
      end
    end
  end
end
