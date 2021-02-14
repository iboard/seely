defmodule Seely.Main do
  @moduledoc """
  The main process (GenServer) for the CLI global handling
  """

  ######################################################################
  use GenServer
  ######################################################################
  defp call(payload) do
    GenServer.call(__MODULE__, payload)
  end

  @doc """
  Start the Main GenServer. Usually done in `Application`
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  ######################################################################
  # API
  ######################################################################

  @doc "Get the pid of the Main process or nil"
  def seely() do
    GenServer.whereis(__MODULE__)
  end

  @doc "Start a new session. Returns `{:ok, pid}` or `{:error, ...}`"
  def start_session(name), do: call({:start_session, name})

  @doc "Stop all sessions"
  def stop_sessions(), do: call(:stop_sessions)

  @doc """
  Get a list of all registered sessions as

      [{"Session 1", pid1}, {"Session 2", pid2}, ...]

  """
  def sessions(), do: call(:sessions)

  @doc """
  Find a session by pid or name.
  Returns the pid when registered or nil.
  """
  def session(pid_or_name), do: call({:session, pid_or_name})

  @doc """
  Get the name of session by pid
  """
  def session_name(pid), do: call({:session_name, pid})

  ######################################################################
  # Callbacks
  ######################################################################

  @impl true
  def init(_state) do
    {:ok, [sessions: []]}
  end

  @impl true
  def handle_call(:sessions, _, state) do
    sessions = Keyword.get(state, :sessions, [])
    {:reply, sessions, state}
  end

  @impl true
  def handle_call({:start_session, name}, _, state) do
    case Seely.Session.start_link(name) do
      {:ok, pid} ->
        state = add_session(state, name, pid)
        {:reply, {:ok, pid}, state}

      error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:stop_sessions, _, state) do
    list_sessions(state)
    |> Enum.each(fn {_name, pid} ->
      GenServer.stop(pid)
    end)

    state =
      state
      |> Keyword.put(:sessions, [])

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:session, pid}, _, state) when is_pid(pid) do
    pid_or_nil =
      find_session_by(state, fn {_name, session_pid} ->
        session_pid == pid
      end)

    {:reply, pid_or_nil, state}
  end

  @impl true
  def handle_call({:session, name}, _, state) when is_binary(name) do
    pid_or_nil =
      find_session_by(state, fn {sname, _session_pid} ->
        sname == name
      end)

    {:reply, pid_or_nil, state}
  end

  @impl true
  def handle_call({:session_name, pid}, _, state) when is_pid(pid) do
    session_name =
      state
      |> Keyword.get(:sessions, [])
      |> Enum.find(fn {_name, p} -> p == pid end)
      |> case do
        nil -> nil
        {found, _} -> found
      end

    {:reply, session_name, state}
  end

  ######################################################################
  # Private Helpers
  ######################################################################

  defp list_sessions(state), do: Keyword.get(state, :sessions, [])

  defp find_session_by(state, fun) do
    state
    |> Keyword.get(:sessions, [])
    |> Enum.find(fn s -> fun.(s) end)
    |> case do
      {_name, spid} -> spid
      _ -> nil
    end
  end

  defp add_session(state, name, pid) do
    state
    |> Keyword.update(:sessions, [], fn sessions ->
      [{name, pid} | sessions]
    end)
  end
end
