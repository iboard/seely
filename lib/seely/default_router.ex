defmodule Seely.DefaultRouter do
  @moduledoc ~s"""
  The default router just defines the echo route for the `Seely.EchoController`

      def routes,
        do: [{"echo", Seely.EchoController, :echo}]

  and it's options `--upper` and `--trim`

      def parse_opts,
        do: [
          strict: [upper: :boolean, trim: :boolean]
        ]

  """

  @doc """
  Returns a list of Tuples of `{ "command", Controller, :function }`
  """
  def routes,
    do: [
      {"echo", Seely.EchoController, :echo}
    ]

  @doc """
  Returns the definiton of options for the `OptionsParser` used in `Seely.Parser`
  """
  def parse_opts,
    do: [
      strict: [upper: :boolean, trim: :boolean]
    ]
end
