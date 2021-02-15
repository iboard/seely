defmodule Seely.Router do
  @moduledoc """
  Functions to find routes in a user-defined router. (See `Seely.DefaultRouter`).
  """

  @doc ~s"""
  Create a new router (which is nothing than a simple `Keyword` list)
  with initially one key only, the `:module` where the actual router is defined.

  Keys: `routes` and `parse_opts` will be added later.
  """
  def new(module) do
    Keyword.new(module: module)
  end

  @doc ~s"""
  Parse the command the user entered.

  The options and routes are fetched from the given `router`
  (See `Seely.DefaultRouter`). The `command` gets parsed by `Seely.Parser` and
  returns a route (`{command,controller,:function}`) for this command if one could be
  found. Otherwise it returns `{:error, "No route found"}`.

  """
  def parse(command, router) do
    options = apply(router, :parse_opts, [])
    routes = apply(router, :routes, [])

    Seely.Parser.parse(command, options)
    |> Seely.Router.find_route(routes)
  end

  @doc """
  Find a route for a given parsed command. A parsed command, as returned from
  `parse/2` has the form

      {parsed_options, parameters, invalid_options}

      # Example: {[upper: true, trim: true], ["echo", " string "], []}

  The function either returns a found route in the form

      {command, controller, :function}

  or, if no function could be found, it returns a route to the `Seely.EchoController`'s
  `:error`-function.

  """
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
