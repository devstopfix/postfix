# credo:disable-for-this-file Credo.Check.Refactor.Apply
defmodule Postfix.Assertions do
  @moduledoc "Assertion helpers (requires module with an eval/1 function)"

  defmacro __using__(opts) do
    eval_module = Keyword.fetch!(opts, :eval)

    quote do
      def eval(terms) do
        apply(unquote(eval_module), :eval, [terms])
      end

      def assert_eval(expected, terms) do
        assert {:ok, expected} == apply(unquote(eval_module), :eval, [terms])
      end

      def refute_eval(expected, terms) do
        assert {:error, expected} == apply(unquote(eval_module), :eval, [terms])
      end
    end
  end
end
