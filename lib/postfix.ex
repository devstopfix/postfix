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
  def eval([f]) when is_function(f) do
    eval_f(f)
  end

  def eval([v]) do
    {:ok, v}
  end

  def eval([f | rest]) when is_function(f) do
    with {:ok, r} <- eval_f(f) do
      eval([r | rest])
    end
  end

  def eval([v | [f | rest]]) when is_function(f) do
    with {:ok, r} <- eval_f(fn -> f.(v) end) do
      eval([r | rest])
    end
  end

  def eval([v1 | [v2 | [f | rest]]]) when is_function(f) do
    with {:ok, r} <- eval_f(fn -> f.(v1, v2) end) do
      eval([r | rest])
    end
  end

  def eval([v1 | [v2 | [v3 | [f | rest]]]]) when is_function(f) do
    with {:ok, r} <- eval_f(fn -> f.(v1, v2, v3) end) do
      eval([r | rest])
    end
  end

  def eval([v1 | [v2 | [v3 | [v4 | [f | rest]]]]]) when is_function(f) do
    with {:ok, r} <- eval_f(fn -> f.(v1, v2, v3, v4) end) do
      eval([r | rest])
    end
  end

  # Arrity 5..255
  def eval(terms) do
    not_function = fn x -> !is_function(x) end

    case Enum.split_while(terms, not_function) do
      {args, [f | rest]} ->
        with {:ok, r} <- eval_f(fn -> apply(f, args) end) do
          eval([r | rest])
        end

      {rest, []} ->
        {:ok, rest}
    end
  end

  defp eval_f(f) do
    case f.() do
      {:error, e} ->
        {:error, e}

      {:ok, v} ->
        {:ok, v}

      v ->
        {:ok, v}
    end
  end
end
