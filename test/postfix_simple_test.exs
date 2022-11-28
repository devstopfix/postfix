defmodule Postfix.SimpleTest do
  use ExUnit.Case
  use Postfix.Assertions, eval: Postfix.Simple
  doctest Postfix.Simple

  describe "eval/1" do
    test "zero arity" do
      assert_eval(self(), [&self/0])
    end

    test "arity one" do
      assert_eval(true, [&self/0, &Process.alive?/1])
    end

    test "arity three" do
      assert_eval("gown", ["down", "d", "g", &String.replace_leading/3])
    end

    test "arity four" do
      assert_eval({:b, 2}, [[a: 1, b: 2], 2, 1, nil, &List.keyfind/4])
    end

    test "arity five" do
      f5 = fn a, b, c, d, e -> a + b + c + d + e end
      assert_eval(15, [1, 2, 3, 4, 5, f5, &Function.identity/1])
    end

    test "terminating with value" do
      assert_eval(1, [1])
    end
  end

  describe "eval/1 with operators" do
    test "arithmetic" do
      assert_eval(4, [3, 4, &-/2, 5, &+/2])
    end
  end
end
