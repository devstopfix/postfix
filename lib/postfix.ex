defmodule Postfix do
  @moduledoc "Evaluator of terms using postfix notation"

  alias Postfix.Simple
  alias Postfix.Stack

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
    Simple.eval(terms)
  end

  @doc """
  Evaluate a list of values and functions using a stack.

  See `Postfix.Stack.eval/1`
  """
  @spec eval_stack([term]) :: {:ok, term} | {:error, any}
  def eval_stack(terms) do
    Stack.eval(terms)
  end
end
