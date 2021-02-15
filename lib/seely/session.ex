defmodule Seely.Session do
  @moduledoc """
  Sessions can be started as registered `GenServer`s and can execute commands
  via `execute/2` and `execute/4` or `batch/2`.

  The concept of sessions is rudimentary implemented. In further versions it will
  enable us to have more named and authorized sessions on a single server. Just
  like a web-server handles different sessions for authorized users/connections.

  But for now, scaling isn't a topic.
  """

  ######################################################################
  use GenServer
  ######################################################################

  defp call(pid, payload) do
    GenServer.call(pid, payload)
  end

  @doc ~s"""
  Start a session. Returns a Tuple of either `{:ok, pid}` or `{:error, reason}`
  """
  def start_link(name) do
    GenServer.start_link(
      __MODULE__,
      %{name: name},
      name: session_reg(name)
    )
  end

  ######################################################################
  # API
  ######################################################################

  @doc ~s"""
  Execute a (string) command in the given `Seely.Session` identified by
  the `pid`.
  """
  def execute(pid, command) when is_pid(pid) and is_binary(command) do
    # Prepare command
    {controller, function, params} = call(pid, {:parse, command})

    apply(controller, function, params)
    # call(pid, {:execute, controller, function, [command]})
  end

  @doc ~s"""
  Execute a `function` in a `controller` with the given `params` in the
  given `Seely.Session` (`pid`)
  """
  def execute(pid, controller, function, params) when is_pid(pid) do
    call(pid, {:execute, controller, function, params})
  end

  @doc ~s"""
  Execute a list of commands in a `Stream`. Returns a list of ok/error Tuples.
  One for each command.

  ### Example

      iex> {:ok, session} = start_session("test")
      ...> batch(session, ["echo hallo world", "echo --upper elixir rocks", "eh?"])
      [
        {:ok, "hello world"},
        {:ok, "ELIXIR ROCKS"},
        {:error, "no route found"}
      ]
  """
  def batch(pid, commands) do
    commands
    |> Stream.map(fn {controller, function, params} ->
      execute(pid, controller, function, params)
    end)
    |> Enum.to_list()
  end

  ######################################################################
  # GenServer Callbacks
  ######################################################################

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:execute, controller, function, params}, _, state) do
    result = apply(controller, function, params)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:parse, command}, _, state) do
    router = Seely.Main.router()
    route = Seely.Router.parse(command, router)

    {:reply, route, state}
  end

  ######################################################################
  # Private helpers
  ######################################################################

  defp session_reg(name) do
    {:global, "Seely.Session." <> name}
  end
end
