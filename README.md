# README

## A CLI-Framework for Elixir

It defines a GenServer `Main` which holds a list of running `Session`s.
The `API` defines all functions provided by Main and Session, thus you can `import Seely.API`
and then call it's functions directly.

    iex> import Seely.API
    iex> cli()

  - `Seely.Main` ......... The main process, started by the application.
  - `Seely.API` .......... A wrapper module to Main you can import where Seely is needed.
  - `Seely.Session` ...... Named sessions - A GenServer handling a CLI-User session.
  - `Seely.Router` ....... Handles the router defined by the user.
  - `Seely.Parser` ....... Helper functions to parse routes.
  - `Seely.EchoController` Defines all the functions your router offers.

## You just implement

  - `YourRouter` ..... Define your controllers and routes.
  - `YourController` . Define the functions for your router.

See `Implementation` below.

## Installation

[Available in Hex](https://hex.pm/packages/seely), the package can be installed
by adding `seely` to your list of dependencies in `mix.exs`:

    def deps do
      [
        {:seely, "~> 0.1.0"}
      ]
    end

Since `Seely` is published on hex the documentation is on
[HexDocs](https://hexdocs.pm) at [https://hexdocs.pm/seely](https://hexdocs.pm/seely).

## Implementation

## Define your router

    defmodule YourApp.YourRouter do
      def routes,
        do: [
          {"echo", Seely.EchoController, :echo},
          {"your_function", YourApp.YourController, :your_function}
        ]

      def parse_opts,
        do: [
          strict: [upper: :boolean, trim: :boolean,
                   myopt: :string]
        ]
    end

`--upper` and `--trim` can be used with the echo command from the `Seely.EchoController`.

## Define your controller

    defmodule YourApp.YourController do

      def your_function(params \\ [""], opts \\ []) do
        myopy = Keyword.get(opts, :myopt, "not found")
        output =
          "Produced by your_function in MyController #{myopy}, #{inspect parmams}"

        {:ok, output}
      end
    end

## Start with your application

    use Application

    def start(_type, _args) do
      children = [
        #...,
        {Seely.Main, YourRouter}
      ]

      opts = [strategy: :one_for_one, name: YourApp.Supervisor]
      Supervisor.start_link(children, opts)
    end

## Start manually

    {:ok, main} = Seely.Main.start_link(YourRouter)


## Usage

Write your Seely-Controllers and Seely-Router and use `Seely.API.cli()` to run a REPL
for your router and controllers.

    iex -S mix  # in your project
    iex> Seely.API.cli
    CLI (1) your_function --myopt "some option" some params
    {:ok, "Produced by your_function in YourController 'some params' '{myopt: 'some option'}"}

    CLI (2) echo --upper --trim " Hello, world!      "
    {:ok, "HELLO, WORLD!"}

    CLI (3) something not implemented
    {:error, "No route found"}

    CLI (4) echo --wrong thing
    {:error, "invalid parameter --wrong"}

    CLI (5) exit
    iex> Ctrl+C

## More to come

In this very early version, `Seely` can run a single loop on a node. Although, the
architecture of `Main` and `Session` will allow to scale in further versions.
