defmodule Seely.Session do
  @moduledoc """
  A CLI Session (GenServer)
  """

  use GenServer

  def start_link(name) do
    GenServer.start_link(
      __MODULE__,
      %{name: name},
      name: session_reg(name)
    )
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  defp session_reg(name) do
    {:global, "Seely.Session." <> name}
  end
end
