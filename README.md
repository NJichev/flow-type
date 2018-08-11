# FlowType

## Add a way to define type specifications with another syntax.

Reasons for this is the more coupled way it ties to the function.
Somewhat inspired by flow.js but more to do with my laziness to
write @spec before the function without the need to type the function
specification twice.

It looks something like this:

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

## TODO

Stuff that are not supported/tested yet:
  - Pattern matching
  - Default arguments
  - Function heads
  - Function guards


## Installation

You can check this out by adding it to your dependencies pointing to
the github repo.
