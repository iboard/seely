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

  def execute(pid, controller, function, params) when is_pid(pid) do
    call(pid, {:execute, controller, function, params})
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

  ######################################################################
  # Private helpers
  ######################################################################

  defp session_reg(name) do
    {:global, "Seely.Session." <> name}
  end
end
