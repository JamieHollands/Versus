defmodule Scrub do
  @moduledoc """
  Scrubs data structures personal information
  """

  import ScrubHelpers, only: [scrub_keys: 1]

  @doc """
  Scrubs -
    Maps | Keyword Lists |
    Maps of Keyword lists | Keyword Lists of Maps |
    Lists of Keyword Lists | Lists of Maps
    Lists of Keyword Lists of Maps | Lists of Maps of Keyword Lists
  of personal information with the keys
    "name", :name,
    "username", :username
    "password", :password
    "email", :email

  Returns scrubbed version of intial datastructure

  #Examples

    iex> Scrub.scrub(%{"scrub" => "map", name: "jamie"})
    %{:name => "******", "scrub" => "map"}

    iex> Scrub.scrub([scrub: "keyword list", email: "Scrub.scrub@ScrubThis.com"])
    [email: "******@ScrubThis.com", scrub: "keyword list"]

    iex> Scrub.scrub(%{maps: [of: "keyword lists", password: "super_secret"]})
    %{maps: [of: "keyword lists", password: "******"]}

    iex> Scrub.scrub([keyword: %{lists: "of maps", username: "obscure_this"}])
    [keyword: %{lists: "of maps", username: "******"}]

    iex> Scrub.scrub([[lists: "of keyword lists"], [name: "jamie"]])
    [[lists: "of keyword lists"], [name: "******"]]

    iex> Scrub.scrub([lists: [[of: %{keyword_lists: "of"}, maps: %{name: "jamie"}], [list2: %{one: 2}, three: %{four: 5}]]])
    [lists: [[maps: %{name: "******"}, of: %{keyword_lists: "of"}],[list2: %{one: 2}, three: %{four: 5}]]]

    iex> Scrub.scrub([lists: [%{of_maps: [of: "keyword_lists"]}, %{list2: [name: "jamie"]}]])
    [lists: [%{of_maps: [of: "keyword_lists"]}, %{list2: [name: "******"]}]]


  """
  @spec scrub(any) :: any
  def scrub(data) do
    scrub?(data)
  end

  # My thought process for handling keyword lists
  # Turn it into a map
  # scrub map accordingly
  # Get keys and values from the map
  # Create new keyword list from scrubbed map keys and values
  # Merge new keyword list onto old keyword list
  # Keyword.merge/2 replaces the keys from arg1 with arg2

  # if data is a list, scrub next index
  # if data is kwl, scrub all maps in the keyword list
  # scrub all other keys
  defp scrub?(data) when is_list(data) do
    if Keyword.keyword?(data) do
      data
      |> scrub_keys()
      |> enum_reduce()
      |> map_keys_and_values()
      |> into_kwl(data)
    else
      Enum.map(data, &scrub?/1)
    end
  end

  # scrub map values
  defp scrub?(data) when is_map(data) do
    data
    |> scrub_keys()
    |> enum_reduce()
  end

  # return data if not map | list | kwl
  defp scrub?(data) do
    data
  end

  # Scrub all maps
  defp enum_reduce(enumerable) do
    enumerable
    |> Enum.reduce(%{}, fn
      {k, v = %{}}, acc -> Map.merge(acc, %{k => scrub?(v)})
      {k, v}, acc -> Map.merge(acc, %{k => scrub?(v)})
    end)
  end

  # Get all keys and values from map and seperate
  defp map_keys_and_values({[], []}), do: {:error, "empty key-value pairs"}

  defp map_keys_and_values(map) do
    keys = Map.keys(map)
    values = Map.values(map)
    {:ok, {keys, values}}
  end

  # use keys from the 'kwl turned map' to update original keys with new scrubed maps
  defp into_kwl({:error, reason}, _), do: IO.puts(reason)

  defp into_kwl({:ok, {keys, values}}, data) do
    new_kwl =

      Enum.zip(keys, values)
      |> Enum.into([], fn {k, v} -> {k, v} end)

    Keyword.merge(data, new_kwl)
  end
end
