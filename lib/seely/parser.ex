defmodule Seely.Parser do
  @moduledoc """
  Helper functions to parse commands.
  """

  @doc """
  Parse the given command and options with the standard `OptionParser`.

  It returns a Tuple of

      { parsed_options, parsed_params, invalid_options }

  Example

      {[upper: true, trim: true], ["echo", " string "], [{:invalid, nil}]}
  """
  def parse(command, opts \\ []) do
    OptionParser.parse(OptionParser.split(command), opts)
  end
end
