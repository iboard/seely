defmodule ControllerTest do
  use ExUnit.Case, async: false

  import Seely.API

  setup _ do
    on_exit(fn -> stop_sessions!() end)

    case Seely.start(TestRouter) do
      {:ok, main} ->
        {:ok, main}

      error ->
        {:error,
         "Can't start Seely with TestController. " <>
           inspect(error)}
    end

    {:ok, session} = start_session("TestSession")
    {:ok, [session: session]}
  end

  test "session can call functions in controller", %{session: sess} do
    assert {:ok, "Hello, world!"} ==
             execute(sess, Seely.EchoController, :echo, ["Hello, world!"])
  end

  test "execute a stream of commands", %{session: sess} do
    commands = [
      {Seely.EchoController, :echo, ["H1"]},
      {Seely.EchoController, :echo, ["H2"]},
      {Seely.EchoController, :echo, ["H3"]}
    ]

    result =
      Stream.map(commands, & &1)
      |> batch(sess)

    expected = [
      {:ok, "H1"},
      {:ok, "H2"},
      {:ok, "H3"}
    ]

    assert result == expected
  end

  test "execute simple command", %{session: sess} do
    assert {:ok, "Hello, world!"} == execute(sess, ~s/echo "Hello, world!"/)
    assert {:ok, "Bye, world!"} == execute(sess, ~s/echo "Bye, world!"/)
  end

  test "execute command with params", %{session: sess} do
    assert {:ok, "STRING"} == execute(sess, ~s/echo --upper --trim " string "/)
  end

  test "render error when invalid params occurs", %{session: sess} do
    assert {:error, {500, "invalid options: [{\"--unknown-option\", nil}]"}} ==
             execute(sess, ~s/echo --unknown-option --trim " string "/)
  end

  test "Example: TestController :copyright", %{session: sess} do
    assert {:ok, "Copyright"} == execute(sess, ~s/copyright/)
    assert {:ok, "(c) 2021"} == execute(sess, ~s/copyright --year 2021/)
    assert {:ok, "(c) 2021 by eh me"} == execute(sess, ~s/copyright --year 2021 by eh me/)
    assert {:ok, "Copyright eh by me"} == execute(sess, ~s/copyright " eh by me"/)
  end

  test "unknown command", %{session: sess} do
    assert {:error, {404, "No route found"}} == execute(sess, ~s/something unknown/)
  end
end
