defmodule Seely.API do
  @moduledoc """
  Import this module when working with Seely.
  It defines all functions, depending on `Seely.Main`
  """

  alias Seely.{
    Main,
    Session
  }

  def seely(),
    do: Main.seely()

  def controllers(),
    do: Main.controllers()

  def controllers(pid) when is_pid(pid),
    do: Main.controllers(pid)

  def sessions(),
    do: Main.sessions()

  def session(pid_or_name),
    do: Main.session(pid_or_name)

  def start_session(name) when is_binary(name),
    do: Main.start_session(name)

  def stop_sessions!(),
    do: Main.stop_sessions()

  def session_name(pid) when is_pid(pid),
    do: Main.session_name(pid)

  def execute(pid, controller, function, params) when is_pid(pid),
    do: Session.execute(pid, controller, function, params)

  def execute(pid, command) when is_pid(pid) and is_binary(command),
    do: Session.execute(pid, command)

  def batch(commands, pid) when is_pid(pid),
    do: Session.batch(pid, commands)
end
