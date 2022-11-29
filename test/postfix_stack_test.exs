defmodule Postfix.StackTest do
  use ExUnit.Case
  use Postfix.Assertions, eval: Postfix.Stack
  doctest Postfix.Stack

  import Function, only: [identity: 1]
  alias Postfix.Stack.{Clear, Dup}

  describe "eval/1" do
    test "empty program returns nil" do
      assert_eval(nil, [])
    end

    test "with one value returns that value" do
      assert_eval(1, [1])
    end

    test "with two values returns last value" do
      assert_eval(2, [1, 2])
    end

    test "with empty stack errors" do
      assert_raise Postfix.Stack.StackError, ~r/empty stack/, fn ->
        eval([&identity/1])
      end
    end

    test "with insufficient values on stack errors" do
      put_new = &Map.put_new/3

      assert_raise Postfix.Stack.StackError, ~r/3 values from stack/, fn ->
        eval([%{a: 1}, :a, put_new])
      end
    end

    test "function with zero arity" do
      assert_eval(self(), [&self/0])
    end

    test "function with zero arity pushes result" do
      assert_eval(true, [true, &self/0, &Process.alive?/1, &and/2])
    end

    test "function with exact arity of values on stack" do
      assert_eval(1, [1, &identity/1])
    end

    test "function with sufficient values on stack" do
      assert_eval(2, [1, 2, &identity/1])
    end

    test "function with arity 2" do
      map_take = &Map.take/2
      assert_eval(%{a: 1}, [%{a: 1, b: 2}, [:a], map_take])
    end

    test "function with arity 3" do
      put_new = &Map.put_new/3
      assert_eval(%{a: 1, b: 2}, [%{a: 1}, :b, 2, put_new])
    end

    test "operand order to operator (subtraction is not cummutative)" do
      assert_eval(38, [40, 2, &-/2])
    end

    test "math operand order" do
      assert_eval(68.0, [20, 9, &*/2, 5.0, &//2, 32, &+/2])
    end

    test "Elixir-lang pipeline" do
      assert_eval(6, [
        "Elixir",
        &String.graphemes/1,
        &Enum.frequencies/1,
        &Map.values/1,
        &Enum.sum/1
      ])
    end

    test "Elixir-lang pipeline with final comparison" do
      assert_eval(true, [
        "Elixir",
        &String.graphemes/1,
        &Enum.frequencies/1,
        &Map.values/1,
        &Enum.sum/1,
        6,
        &==/2
      ])
    end

    test "continues when function returns :error atom" do
      assert_eval(:error, ["fab", 10, &Integer.parse/2])
    end

    test "halts with reason when function returns :error tuple" do
      refute_eval(:invalid_format, ["next Thursday", &DateTime.from_iso8601/1, &Atom.to_string/1])
    end

    test "errors are returned as tuples" do
      terms = [[{:a, 1}], :b, &Keyword.fetch!/2]
      assert {:error, %KeyError{key: :b, term: [a: 1]}} = eval(terms)
    end
  end

  describe "eval/1 stack shuffling" do
    test "clear" do
      assert_eval(nil, [1, 2, 3, Clear])
      assert_eval(3, [1, 2, Clear, 3])
    end

    test "duplicate" do
      assert_eval(2, [1, Dup, &+/2])
    end
  end
end
