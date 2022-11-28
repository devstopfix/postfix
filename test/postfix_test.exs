defmodule PostfixTest do
  use ExUnit.Case
  doctest Postfix

  import Postfix, only: [eval: 1]

  describe "README" do
    test "example" do
      assert_eval(20, [7, 2, &-/2, 4, &*/2])
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
