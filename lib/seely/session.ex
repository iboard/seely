defmodule Seely.Session do
  @moduledoc """
  A CLI Session (GenServer)
  """

  ######################################################################
  use GenServer
  ######################################################################

  defp call(pid, payload) do
    GenServer.call(pid, payload)
  end

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

  def execute(pid, command) when is_pid(pid) and is_binary(command) do
    # Prepare command
    {controller, function, params} = call(pid, {:parse, command})

    apply(controller, function, params)
    # call(pid, {:execute, controller, function, [command]})
  end

  def execute(pid, controller, function, params) when is_pid(pid) do
    call(pid, {:execute, controller, function, params})
  end

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
