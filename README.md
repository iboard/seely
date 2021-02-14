# Seely

A CLI-Framework for Elixir

  - `Seely.Main` ..... The main process, started by the application.
  - `Seely.API` ...... A wrapper module to Main you can import where Seely is needed.
  - `Seely.Session` .. Named sessions - A GenServer handling a CLI-User session.

## Installation

[Available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `seely` to your list of dependencies in `mix.exs`:

    def deps do
      [
        {:seely, "~> 0.1.0"}
      ]
    end

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/seely](https://hexdocs.pm/seely).

## Usage

Write your Seely-Controllers and add Seele to the children of your Application.


    use Application

    def start(_type, _args) do
      children = [
        #...,
        {Seely.Main, [YourController, YourOtherController, ...]}
      ]

      # See https://hexdocs.pm/elixir/Supervisor.html
      # for other strategies and supported options
      opts = [strategy: :one_for_one, name: Seely.Supervisor]
      Supervisor.start_link(children, opts)
    end


If you have only one controller you can write it shorter, like so

    children = [
      # ...,
      {Seely.Main, YourController}
    ]


