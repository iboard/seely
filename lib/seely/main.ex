defmodule Seely.Main do
  @moduledoc """
  The main process (GenServer) for the CLI global handling
  """
  alias Seely.API

  ######################################################################
  use GenServer
  ######################################################################
  defp call(payload) do
    if GenServer.whereis(__MODULE__),
      do: GenServer.call(__MODULE__, payload),
      else: {:error, "Server #{__MODULE__} not running"}
  end

  @doc """
  Start the Main GenServer. Usually done in `Application`
  and/or test setups.
  """
  def start_link(router_module) do
    GenServer.start_link(__MODULE__, router_module, name: __MODULE__)
  end

  ######################################################################
  # API
  ######################################################################

  @doc "Get the pid of the Main process or nil"
  def seely() do
    GenServer.whereis(__MODULE__)
  end

  @doc "Start the CLI loop"
  def cli(_opts \\ []) do
    {:ok, sess} = start_session("CLI")
    loop(sess)
  end

  @doc "Get the router"
  def router(), do: call(:router)

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
  def init(router_module) do
    router_module
    |> validate_router()
    |> build_state()
  end

  @impl true
  def handle_call(:router, _, router) do
    router_module =
      Keyword.get(router, :module, {:error, "Router not defined in #{inspect(router)}"})

    {:reply, router_module, router}
  end

  @impl true
  def handle_call(:sessions, _, router) do
    sessions = Keyword.get(router, :sessions, [])
    {:reply, sessions, router}
  end

  @impl true
  def handle_call({:start_session, name}, _, router) do
    case Seely.Session.start_link(name) do
      {:ok, pid} ->
        router = add_session(router, name, pid)
        {:reply, {:ok, pid}, router}

      error ->
        {:reply, error, router}
    end
  end

  @impl true
  def handle_call(:stop_sessions, _, router) do
    list_sessions(router)
    |> Enum.each(fn {_name, pid} ->
      GenServer.stop(pid)
    end)

    router =
      router
      |> Keyword.put(:sessions, [])

    {:reply, :ok, router}
  end

  @impl true
  def handle_call({:session, pid}, _, router) when is_pid(pid) do
    pid_or_nil =
      find_session_by(router, fn {_name, session_pid} ->
        session_pid == pid
      end)

    {:reply, pid_or_nil, router}
  end

  @impl true
  def handle_call({:session, name}, _, router) when is_binary(name) do
    pid_or_nil =
      find_session_by(router, fn {sname, _session_pid} ->
        sname == name
      end)

    {:reply, pid_or_nil, router}
  end

  @impl true
  def handle_call({:session_name, pid}, _, router) when is_pid(pid) do
    session_name =
      router
      |> Keyword.get(:sessions, [])
      |> Enum.find(fn {_name, p} -> p == pid end)
      |> case do
        nil -> nil
        {found, _} -> found
      end

    {:reply, session_name, router}
  end

  ######################################################################
  # Private Helpers
  ######################################################################

  defp validate_router(router_module) do
    router = Seely.Router.new(router_module)

    if Keyword.get(router, :module, false) == router_module,
      do: {:ok, router},
      else: {:error, "Router is invalid. (#{inspect(router)})"}
  end

  defp build_state({:error, _} = e), do: e

  defp build_state({:ok, router}) do
    router =
      router
      |> Keyword.put_new(:sessions, [])

    {:ok, router}
  end

  defp list_sessions(router), do: Keyword.get(router, :sessions, [])

  defp find_session_by(router, fun) do
    router
    |> Keyword.get(:sessions, [])
    |> Enum.find(fn s -> fun.(s) end)
    |> case do
      {_name, spid} -> spid
      _ -> nil
    end
  end

  defp add_session(router, name, pid) do
    router
    |> Keyword.update(:sessions, [], fn sessions ->
      [{name, pid} | sessions]
    end)
  end

  defp loop(session, cnt \\ 1) do
    if prompt(cnt, session)
       |> execute_cmd(cnt, session)
       |> loop_or_stop(),
       do: loop(session, cnt + 1)
  end

  defp prompt(cnt, session) do
    IO.gets("#{session_name(session)} (#{cnt})>")
    |> String.trim()
  end

  def execute_cmd(_, "exit", _session) do
    API.stop_sessions!()
    IO.puts("Goodbye!")
    "exit"
  end

  def execute_cmd(command, cnt, session) do
    API.execute(session, command)
    |> IO.inspect(label: "##{cnt} =>")
  end

  defp loop_or_stop(cmd) do
    cmd != "exit"
  end
end
