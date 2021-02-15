defmodule TestController do
  @moduledoc """
  An implementation for Tests
  """

  def test(params \\ [""], opts \\ []) do
    output =
      if _year = Keyword.get(opts, :year, false),
        do: "(c) #{Enum.join(params, " ")}",
        else: "Copyright#{Enum.join(params, " ")}"

    {:ok, output}
  end
end
