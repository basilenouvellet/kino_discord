defmodule KinoDiscord.Helpers do
  @moduledoc false

  @doc """
  ## Examples

      iex> all_fields_filled?(%{"key1" => "value1", "key2" => "value2"}, ~w(key1 key2))
      true

      iex> all_fields_filled?(%{"key1" => "value1"}, ~w(key1))
      true

      iex> all_fields_filled?(%{"key1" => "value1", "key2" => ""}, ~w(key1 key2))
      false

      iex> all_fields_filled?(%{"key1" => "", "key2" => ""}, ~w(key1 key2))
      false

      iex> all_fields_filled?(%{"key1" => nil, "key2" => "value2"}, ~w(key1 key2))
      false

      iex> all_fields_filled?(%{"key1" => "value1"}, ~w(key1 key2))
      false
  """
  def all_fields_filled?(attrs, keys) do
    Enum.all?(keys, fn key -> attrs[key] not in [nil, ""] end)
  end
end
