defmodule Seely.Router do
  @moduledoc """
  The router parses a command and returns a tupple of `{controller, function, params}`
  """
  def new(module) do
    Keyword.new(module: module)
  end

  def parse(command, router) do
    options = apply(router, :parse_opts, [])
    routes = apply(router, :routes, [])

    Seely.Parser.parse(command, options)
    |> Seely.Router.find_route(routes)
  end

  # {[upper: true, trim: true], ["echo", " string "], []}
  def find_route(parsed_command, routes) do
    case parsed_command do
      {opts, [cmd | params], []} ->
        routes
        |> Enum.find(fn {c, _controller, _function} ->
          cmd == c
        end)
        |> build_route(opts, params)

      {_opts, [_cmd | _params], invalid_options} ->
        {Seely.EchoController, :error,
         [
           {500,
            "invalid options: #{
              inspect(invalid_options,
                pretty: true
              )
            }"}
         ]}

      unknown ->
        {Seely.EchoController, :echo, ["No route #{inspect(unknown)}"]}
    end
  end

  defp build_route(nil, _opts, _params) do
    {Seely.EchoController, :error, [{404, "No route found"}]}
  end

  defp build_route({_cmd, controller, function}, opts, params) do
    {controller, function, [params, Keyword.new(opts)]}
  end
end
