defmodule ControllerTest do
  use ExUnit.Case, async: false

  import Seely.API
  alias Seely.TestController

  setup _ do
    on_exit(fn -> stop_sessions!() end)

    case Seely.start(TestController) do
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

  test "controllers are configured properly" do
    assert controllers() == [TestController]
  end

  test "session can reach controller", %{session: sess} do
    assert controllers(sess) == [TestController]
  end

  test "session can call functions in controller", %{session: sess} do
    assert {:ok, "Hello, world!"} ==
             execute(sess, Seely.EchoController, :echo, ["Hello, world!"])
  end
end
