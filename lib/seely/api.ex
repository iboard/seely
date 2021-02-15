defmodule Seely.API do
  @moduledoc """
  An importable wrapper for functions in `Seely.Main`. You can import this module
  for convenience.

  ### Example

      import Seely.API

      {:ok, session} = start_session("Session one")
      execute(session, "echo hello world"


  """

  alias Seely.{
    Main,
    Session
  }

  @doc "Get the pid of the main process"
  def seely(),
    do: Main.seely()

  @doc "Run the cli loop"
  def cli(),
    do: Main.cli()

  @doc "Get the list of running sessions"
  def sessions(),
    do: Main.sessions()

  @doc "Find a session's pid by either it's pid (usefull in pipes) or it's name."
  def session(pid_or_name),
    do: Main.session(pid_or_name)

  @doc "Start a named session"
  def start_session(name) when is_binary(name),
    do: Main.start_session(name)

  @doc "Stop all sessions"
  def stop_sessions!(),
    do: Main.stop_sessions()

  @doc "Get the name of a session"
  def session_name(pid) when is_pid(pid),
    do: Main.session_name(pid)

  @doc "Execute `function` in `controller` with `params`"
  def execute(pid, controller, function, params) when is_pid(pid),
    do: Session.execute(pid, controller, function, params)

  @doc "Execute a command-string in a given session"
  def execute(pid, command) when is_pid(pid) and is_binary(command),
    do: Session.execute(pid, command)

  @doc "Execute a `Stream` of commands in session `pid`"
  def batch(commands, pid) when is_pid(pid),
    do: Session.batch(pid, commands)
end
