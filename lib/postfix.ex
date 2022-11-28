defmodule Postfix do
  @moduledoc "Evaluator of terms using postfix notation"

  @doc """
  Evaluate a list of values and functions

      iex> Postfix.eval([2, 3, &*/2, 4, &+/2])
      {:ok, 10}

      iex> Postfix.eval([1, 2, &-/2])
      {:ok, -1}

  Operands are given to the function in the natural left-to-right order.
  All operands are consumed by the function - the arity is not checked.
  """
  @spec eval([term]) :: {:ok, term} | {:error, any}
  def eval(terms) do
    Postfix.Simple.eval(terms)
  end
end
