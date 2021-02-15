defmodule Seely.Parser do
  @moduledoc """
  Router functions
  """

  def parse(command, opts \\ []) do
    OptionParser.parse(OptionParser.split(command), opts)
    # {[upper: true, trim: true], ["echo", " string "], [{:invalid, nil}]}
  end
end
