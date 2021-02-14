defmodule Seely.API do
  @moduledoc """
  Import this module when working with Seely.
  It defines all functions, depending on `Seely.Main`
  """

  alias Seely.Main

  def seely(),
    do: Main.seely()

  def controllers(),
    do: Main.controllers()

  def sessions(),
    do: Main.sessions()

  def session(pid),
    do: Main.session(pid)

  def start_session(name),
    do: Main.start_session(name)

  def stop_sessions!(),
    do: Main.stop_sessions()

  def session_name(pid) when is_pid(pid),
    do: Main.session_name(pid)
end
