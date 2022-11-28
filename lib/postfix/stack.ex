defmodule Postfix.Stack do
  @moduledoc "Evaluation of terms using postfix order and a stack"

  defmodule StackError do
    @moduledoc "Raised when stack has insufficient values available for the arity of the function"
    defexception [:message, :stack]

    @impl true
    def exception(arity: 1, stack: [] = stack) do
      msg = "Cannot pop value from empty stack"
      %__MODULE__{message: msg, stack: stack}
    end

    def exception(arity: arity, stack: stack) do
      msg = "Cannot pop #{Integer.to_string(arity)} values from stack"
      %__MODULE__{message: msg, stack: stack}
    end
  end

  @doc """
  Evaluate a list of values and functions using a stack.

      iex> Postfix.Stack.eval([2, 3, &*/2, 4, &+/2])
      {:ok, 10}

      iex> Postfix.Stack.eval([1, 2, &-/2])
      {:ok, -1}

  Values are pushed on to the stack.

  Functions are defined by their arity and there must be sufficient operands available
  on the stack otheriwse `Postfix.Stack.StackError` is raised. Operands are
  given to the function in fifo order (left-to-right).

  The return value of any function is pushed onto the stack. If the function
  returns an `{:ok, value}` tuple then the value is unwrapped. If any function
  returns an `{:error, error}` tuple then the evaluation is short-circuited
  and the error tuple is returned.

  Returns the last value on the stack within an `{:ok, ...}` tuple,
  or `{:ok, nil}` if the stack is empty.
  """
  @spec eval([term]) :: {:ok, term} | {:error, any}
  def eval(terms) when is_list(terms) do
    empty_stack = []
    eval_with_stack(terms, empty_stack)
  end

  defp eval_with_stack([], []), do: {:ok, nil}
  defp eval_with_stack([], [v | _]), do: {:ok, v}

  defp eval_with_stack([f | rest], stack) when is_function(f) do
    {:arity, arity} = :erlang.fun_info(f, :arity)
    {rev_args, new_stack} = Enum.split(stack, arity)

    if Enum.count(rev_args) != arity do
      raise StackError, arity: arity, stack: stack
    end

    args = Enum.reverse(rev_args)

    case(apply(f, args)) do
      {:error, error} ->
        {:error, error}

      {:ok, v} ->
        eval_with_stack(rest, [v | new_stack])

      v ->
        eval_with_stack(rest, [v | new_stack])
    end
  end

  # Push value onto stack
  defp eval_with_stack([v | rest], stack) do
    eval_with_stack(rest, [v | stack])
  end
end
