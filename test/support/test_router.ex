defmodule TestRouter do
  def routes,
    do: [
      {"echo", Seely.EchoController, :echo},
      {"copyright", TestController, :test}
    ]

  def parse_opts,
    do: [
      strict: [upper: :boolean, trim: :boolean, year: :boolean]
    ]
end
