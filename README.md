# Postfix

Simple evaluator of a list of values and functions given in [postfix][postfix] order. 

```elixir
{:ok, 10} = Postfix.eval([2, 3, &*/2, 4, &+/2])
```

## Usage

Functions are evaluated with all the operands to their left, and the result
replaces the function it's operands in the list and evaluation continues.

If any function returns an `{:ok, value}` tuple then the value is unwrapped
and used as the result.

Any function that fails with an `{:error, _}` tuple short-circuits and 
becomes the result of the evaluation,

### Limitations

It is not possible to pass a function to a higher-order function as it will be evaluated.

Given the filter example:

```elixir
is_odd? = fn x -> rem(x, 2) == 0 end
Enum.filter(1..3, is_odd?)
```

This *cannot* be written as:

```elixir
is_odd? = fn x -> rem(x, 2) == 0 end

{:ok, [2]} = Postfix.eval([1..3, is_odd?, &Enum.filter/2])
```

However it could be written as:

```elixir
is_odd? = fn x -> rem(x, 2) == 0 end
filter_odd = fn xs -> Enum.filter(xs, is_odd?) end

{:ok, [2]} = Postfix.eval([1..3, filter_odd])
```

### Improvements

A stack will be added so results of multiple functions can become inputs
to another function.

## Installation

This package can be installed
by adding `postfix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:postfix, "~> 1.0"}
  ]
end
```

[postfix]: https://en.wikipedia.org/wiki/Reverse_Polish_notation