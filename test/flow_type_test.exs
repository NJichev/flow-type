defmodule FlowTypeTest do
  use ExUnit.Case
  doctest FlowType

  defmacrop test_module(do: block) do
    quote do
      {:module, _, bytecode, _} =
        defmodule SampleModule do
          unquote(block)
        end

      purge(SampleModule)
      bytecode
    end
  end

  defp purge(module) do
    :code.delete(module)
    :code.purge(module)
  end

  @skip_specs [__info__: 1]

  defp specs(bytecode) do
    bytecode
    |> Code.Typespec.fetch_specs()
    |> elem(1)
    |> Enum.reject(fn {sign, _} -> sign in @skip_specs end)
    |> Enum.sort()
  end

  test "function can be defined without types" do
    defmodule Test do
      use FlowType

      def add(a, b) do
        a + b
      end
    end

    assert Test.add(3, 4) == 7
    purge(Test)
  end

  test "function can be defined with types" do
    defmodule Test do
      use FlowType

      def add(a: integer, b: integer) :: integer do
        a + b
      end
    end

    assert Test.add(3, 4) == 7
    purge(Test)
  end

  test "types are compiled to normal @specs as expected" do
    bytecode =
      test_module do
        use FlowType

        def my_fun1(x: integer) :: integer, do: x
        def my_fun2() :: integer, do: :ok
        def my_fun3(x: integer, y: integer) :: {integer, integer}, do: {x, y}
      end

    assert [my_fun1, my_fun2, my_fun3] = specs(bytecode)

    assert {{:my_fun1, 1}, [{:type, _, :fun, args}]} = my_fun1
    assert [{:type, _, :product, [{:type, _, :integer, []}]}, {:type, _, :integer, []}] = args

    assert {{:my_fun2, 0}, [{:type, _, :fun, args}]} = my_fun2
    assert [{:type, _, :product, []}, {:type, _, :integer, []}] = args

    assert {{:my_fun3, 2}, [{:type, _, :fun, [arg1, arg2]}]} = my_fun3
    assert {:type, _, :product, [{:type, _, :integer, []}, {:type, _, :integer, []}]} = arg1
    assert {:type, _, :tuple, [{:type, _, :integer, []}, {:type, _, :integer, []}]} = arg2
  end

  test "multiple clause definitions" do
    {:module, _, bytecode, _} =
      defmodule TestClauses do
        use FlowType

        def my_fun(x: integer) :: integer when is_integer(x), do: x
        def my_fun(x: atom) :: atom, do: :foo
      end

    assert TestClauses.my_fun(3) == 3
    assert TestClauses.my_fun(:asdf) == :foo

    assert [{{:my_fun, 1}, [integer, atom]}] = specs(bytecode)
    assert {:type, _, :fun, [{:type, _, :product, [{:type, _, :integer, []}]}, {:type, _, :integer, []}]} = integer
    assert {:type, _, :fun, [{:type, _, :product, [{:type, _, :atom, []}]}, {:type, _, :atom, []}]} = atom
  end
end
