# FlowType

FlowType inspired by flow.js and laziness from writing `@spec`s in
your code aims to simplify type annotation for your functions:

```
defmodule Module do
  use FlowType

  def add(a: integer, b: integer) :: integer do
    a + b
  end
end
```

This will compile to, you guessed it, this code:

```
defmodule Module do
  @spec add(integer, integer) :: integer
  def add(a, b) do
    a + b
  end
end
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `flow_type` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flow_type, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/flow_type](https://hexdocs.pm/flow_type).

