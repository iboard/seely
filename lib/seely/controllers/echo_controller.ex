defmodule Seely.EchoController do
  @moduledoc """
  A minimal implementation of a controller
  """

  def echo(string, opts \\ []) do
    output =
      string
      |> format(opts)
      |> maybe_upper(opts)
      |> maybe_trim(opts)
      |> maybe_append_ignored_options(opts)

    {:ok, output}
  end

  def error(err, opts \\ []) do
    {:error, err}
  end

  defp maybe_append_ignored_options(str, opts) do
    ignored = Keyword.drop(opts, [:upper, :trim])

    if ignored == [],
      do: str,
      else: str <> "(ignored options: #{inspect(ignored)})"
  end

  defp format(str, _opts) when is_list(str), do: Enum.join(str)
  defp format(str, _opts) when is_binary(str), do: str

  defp maybe_upper(str, opts) do
    if Keyword.get(opts, :upper, false), do: String.upcase(str), else: str
  end

  defp maybe_trim(str, opts) do
    if Keyword.get(opts, :trim, false), do: String.trim(str), else: str
  end
end
