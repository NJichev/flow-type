defmodule FlowType do
  require Kernel

  @moduledoc """
  Flow Type redefines def in order to let users annotate their function types faster.
  Kinda inspired by flow.js and specs being awkward :P
  """

  @doc """
  Allows users to define type specifications with a nicer syntax.

  You can use normal definitions or mix them however you like, depending
  on whether you want type specifications.

  Example:

      iex> defmodule Module do
      ...>   use FlowType
      ...>   def square(n: integer) :: integer, do: n * n
      ...>   def add(a: integer, b: integer) :: integer, do: a + b
      ...> end
      iex> Module.square(3)
      9
      iex> Module.add(3, 4)
      7
  """
  defmacro def(body, expr \\ nil)
  defmacro def({:::, _meta, [{name, line, args}, return_type]}, expr) do
    {body_args, types} = split_types(args)
    body = {name, line, body_args}

    quote do
      @spec(unquote(name)(unquote_splicing(types)) :: unquote(return_type))
      Kernel.def(unquote(body), unquote(expr))
    end
  end

  defmacro def(body, expr) do
    quote do
      Kernel.def(unquote(body), unquote(expr))
    end
  end

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [def: 2]
      import unquote(__MODULE__)
    end
  end

  defp split_types([]), do: {[], []}
  defp split_types([[]]), do: {[], []}
  defp split_types([[{name, {type, meta, nil}} | rest]]) do
    # Lazy to optimize this
    {args, types} = split_types([rest])
    {[{name, meta, nil} | args], [{type, meta, nil} | types]}
  end
end
