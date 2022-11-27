defmodule PostfixTest do
  use ExUnit.Case
  doctest Postfix

  import Postfix, only: [eval: 1]

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

  describe "README" do
    test "example" do
      assert_eval(10, [2, 3, &*/2, 4, &+/2])
    end

    test "high-order functions fail" do
      is_odd? = fn x -> rem(x, 2) == 0 end
      terms = [1..3, is_odd?, &Enum.filter/2]

      assert_raise ArithmeticError, fn ->
        eval(terms)
      end
    end

    test "filter" do
      is_odd? = fn x -> rem(x, 2) == 0 end
      filter_odd = fn xs -> Enum.filter(xs, is_odd?) end
      assert_eval([2], [1..3, filter_odd])
    end
  end

  defp assert_eval(expected, terms) do
    assert {:ok, expected} == eval(terms)
  end
end
