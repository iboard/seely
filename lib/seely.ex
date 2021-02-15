defmodule Seely do
  @moduledoc """
  Starting the main-process (a `GenServer`) with a given router


  ### Example

      defmodule MyRouter do

        def routes,
          do: [
            {"myfunc", MyController, :myfunc}
          ]

        def parse_opts,
          do: [
            strict: [myoption: boolean]
          ]
      end

      defmodule MyController do
        def myfunc(params \\ [""], opts \\ []) do
          output =
            if Keyword.get(opts, :myopt, false) do
              ... code with 'myopt' true ...
            else
              ... code with 'myopt' false or not given
            end

          {:ok, output}
        end
      end


      Seely.Main.start_link(MyRouter)

      Seely.API.cli
      CLI(1) myfunc --myopt
      {:ok, "...code with 'myopt' on..."}
      CLI(2) myfunc
      {:ok, "...code with 'myopt' off..."}
      CLI(3) exit

  """

  alias Seely.Main

  @doc """
  Start the main process with the given router.

  Returns `{:ok, pid}`.

  Usually this server pid won't be used because `Main` is a named (singelton)
  process. You can find the pid at any time with `GenServer.whereis(Seely.Main)`.
  """
  @spec start(any()) :: {:ok, pid} | {:error, any()}
  def start(router) do
    Main.start_link(router)
  end
end
