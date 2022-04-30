defmodule ScrubHelpers do
  @moduledoc """
  Contains the functions that scrub the values
  from the keys name, username, password, email
  """
  @keys [:name, "name", :username, "username", :password, "password"]
  @email_keys [:email, "email"]

  @doc """
  Searches a map or keyword list for a the keys
  name, username, password, and email and updates their
  values to "******" or "******@email.com"

  Returns updated map or keyword list
  lists and tuples are returned untouched

  #Examples
    iex> ScrubHelpers.scrub_keys(%{})
    %{}

    iex> ScrubHelpers.scrub_keys([])
    []

    iex> ScrubHelpers.scrub_keys(["regular", "list"])
    ["regular", "list"]

    iex> ScrubHelpers.scrub_keys({"just", :a, "tuple"})
    {"just", :a, "tuple"}

    iex> ScrubHelpers.scrub_keys([scrubbed: "keywordlist", name: "jamie"])
    [scrubbed: "keywordlist", name: "******"]

    iex> ScrubHelpers.scrub_keys(%{email: "email@scrubbed_map"})
    %{email: "******@scrubbed_map"}

  """
  @spec scrub_keys(any) :: any
  def scrub_keys(data) do
    not_kwl?(data)
  end

  # if list but not a keyword list, return to prevent using it in Keyword.replace
  # otherwise continue
  defp not_kwl?(data) when is_list(data) do
    case Keyword.keyword?(data) do
      true ->
        scrub_keys?(data)

      false ->
        data
    end
  end

  defp not_kwl?(data), do: scrub_keys?(data)

  defp scrub_keys?(data) do
    data
    |> has_key?(@keys)
    |> has_email_key?(@email_keys)
  end

  # Checks that a map or keyword list has a key by iterating
  # through the the predefined keys
  defp has_key?(data, [head | tail]) when is_list(data) and is_atom(head) do
    Keyword.replace(data, head, "******")
    |> has_key?(tail)
  end

  defp has_key?(data, [head | []]) when is_list(data) and is_atom(head) do
    Keyword.replace(data, head, "******")
  end

  defp has_key?(data, [head | tail]) when is_list(data) and is_atom(head) do
    Keyword.replace(data, head, "******")
    |> has_key?(tail)
  end

  defp has_key?(data, [head | []]) when is_map_key(data, head) do
    Map.update(data, head, "", fn _val -> "******" end)
  end

  defp has_key?(data, [head | tail]) when is_map_key(data, head) do
    Map.update(data, head, "", fn _val -> "******" end)
    |> has_key?(tail)
  end

  defp has_key?(data, [_head | []]), do: data
  defp has_key?(data, [_head | tail]), do: has_key?(data, tail)

  # Checks to see if the map or keyword list contains an email key
  # if it does obscure it
  defp has_email_key?(data, [head | []]) when is_list(data) and is_atom(head) do
    Keyword.replace(data, head, scrub_email(Keyword.get(data, head)))
  end

  defp has_email_key?(data, [head | tail]) when is_list(data) and is_atom(head) do
    Keyword.replace(data, head, scrub_email(Keyword.get(data, head)))
    |> has_key?(tail)
  end

  defp has_email_key?(data, [head | []]) when is_map_key(data, head) do
    Map.update(data, head, "", fn val -> scrub_email(val) end)
  end

  defp has_email_key?(data, [head | tail]) when is_map_key(data, head) do
    Map.update(data, head, "", fn val -> scrub_email(val) end)
    |> has_key?(tail)
  end

  defp has_email_key?(data, [_head | []]), do: data
  defp has_email_key?(data, [_head | tail]), do: has_key?(data, tail)

  defp scrub_email(nil), do: nil
  defp scrub_email(""), do: ""

  # checks for a valid email
  # if it is valid replace until @
  # if it is invalid replace with "******"
  defp scrub_email(email) do
    scrub_email(
      String.contains?(email, "@"),
      email
    )
  end

  defp scrub_email(true, email) do
    String.replace(email, ~r{(.+?)(?=@)}iu, "******")
  end

  defp scrub_email(false, email) do
    String.replace(email, ~r{(.+?)(?=$)}iu, "******")
  end
end
