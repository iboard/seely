defmodule SeelyTest do
  use ExUnit.Case, async: false
  doctest Seely

  import Seely.API

  setup do
    case Seely.start(TestRouter) do
      {:ok, main} -> {:ok, main}
      error -> raise "Can't start Seely with TestController. #{inspect(error)}"
    end

    :ok
  end

  describe "Basic API" do
    setup do
      on_exit(fn -> stop_sessions!() end)
    end

    test "Main process started" do
      assert is_pid(Seely.Main.seely())
    end

    test ".sessions()" do
      assert sessions() == []
    end

    test ".start_session(name)" do
      {:ok, session} = start_session("TestSession")
      assert is_pid(session)
    end

    test "session name is unique" do
      {:ok, session} = start_session("TestSession")
      {:error, {:already_started, ^session}} = start_session("TestSession")
    end

    test ".session(pid) finds a session by pid" do
      {:ok, session} = start_session("TestSession")
      assert session == session(session)
      assert nil == session(self())
    end

    test ".session(name) finds a session by name" do
      {:ok, session} = start_session("TestSession")
      assert session == session("TestSession")
    end
  end

  describe "Session" do
    setup _ do
      on_exit(fn -> stop_sessions!() end)

      {:ok, session} = start_session("TestSession")
      {:ok, [session: session]}
    end

    test ".session_name(pid) get the name of the session", %{session: session} do
      assert session_name(session) == "TestSession"
    end
  end
end
