# credo:disable-for-this-file Credo.Check.Refactor.Apply
defmodule Postfix.Assertions do
  @moduledoc "Assertion helpers (requires module with an eval/1 function)"

  defmacro __using__(opts) do
    eval_module = Keyword.fetch!(opts, :eval)

    quote do
      # Evaluate the program
      def eval(terms) do
        apply(unquote(eval_module), :eval, [terms])
      end

      # Assert the program succeeds and returns the expected output
      def assert_eval(expected, terms) do
        ExUnit.Assertions.assert({:ok, expected} == apply(unquote(eval_module), :eval, [terms]))
      end

      # Assert the program fails and returns the expected error
      def refute_eval(expected, terms) do
        ExUnit.Assertions.assert(
          {:error, expected} == apply(unquote(eval_module), :eval, [terms])
        )
      end
    end
  end
end
