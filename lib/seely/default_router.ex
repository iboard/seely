defmodule Seely.DefaultRouter do
  def routes,
    do: [
      {"echo", Seely.EchoController, :echo}
    ]

  def parse_opts,
    do: [
      strict: [upper: :boolean, trim: :boolean]
    ]
end
