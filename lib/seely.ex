defmodule Seely do
  @moduledoc """
  Seely is a Hex package, implementing a Command Line Interface
  usable in all Elixir-applications.

  Seely starts one singelton GenServer (Seely.Main) and maintains
  `Seely.Session`s as sub-processes for each client session.

  Just import `Seely.API` in your app.


  ### Example

      import Seely.API

      {:ok, session} = start_session("Terminalname")
      run_session(session, fn(sess) ->
        ...
      end)

  or do the same with less code

     start_session!("Terminalname")
     |> run_session( fn(sess) ->
     end)

  """

  alias Seely.Main

  def start(router) do
    Main.start_link(router)
  end
end
