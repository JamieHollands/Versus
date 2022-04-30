defmodule JsonScrub do
  import JsonScrubHelpers, only: [open_file: 1]

  @moduledoc """
  Scrub .json files to obscure personal/private information
  """

  @spec json_from_file(any) :: atom | {:error, atom | <<_::208>>}
  @doc """
  Takes .json file location as a binary
  uses the default key values of "name", "username", "password", "email"

  Outputs a new file "input_file_name"_scrubbed.json in
  the same directory

  ## Examples

    iex> JsonScrub.json_from_file("./test_files/user_1.json")
    :ok

    iex> JsonScrub.json_from_file("not_an_actual_file.json")
    :enoent

    iex(1)> JsonScrub.json_from_file(:atom_not_binary)
    {:error, "file name must be a binary"}

  """
  def json_from_file(file_name) when is_binary(file_name) do
    case open_file(file_name) do
      {:ok, file} ->
        String.replace(file_name, ~r{(.+?)(?=\.json)}, "\\g{1}_scrubbed")
        |> File.write(scrub_json(file))

      {:error, reason} ->
        reason
    end
  end

  def json_from_file(_file_name), do: {:error, "file name must be a binary"}

  @spec json_from_file(any, any) :: atom | {:error, atom | <<_::208>>}
  @doc """
  Takes .json file location as a binary and a set of keys

  key can be a map, list, binary, or atom

  Outputs a new file "input_file_name"_scrubbed.json in
  the same directory

  ## Examples

    iex> JsonScrub.json_from_file("./test_files/user_1.json", ["email", "name"])
    :ok

    iex> JsonScrub.json_from_file("not_an_actual_file.json", ["email", "username"])
    :enoent

    iex> JsonScrub.json_from_file(:atom_not_binary, ["email", "username"])
    {:error, "file name must be a binary"}

  """
  def json_from_file(file_name, key) when is_binary(file_name) do
    case open_file(file_name) do
      {:ok, file} ->
        String.replace(file_name, ~r{(.+?)(?=\.json)}, "\\g{1}_scrubbed")
        |> File.write(scrub_json(file, key))

      {:error, reason} ->
        reason
    end
  end

  # catch all for file names that are not binaries
  def json_from_file(_file_name, _key), do: {:error, "file name must be a binary"}

  @doc """
  Scrubs specified keys in a binary and obscures their value
  Accepts all binarys, use json_from_file to ensure .json extension

  Returns a scrubbed file/binary

  ## Examples

    iex> JsonScrub.scrub_json("{\\n \\"id\\": 123,\\n \\"name\\": \\"Elle\\"}")
    "{\\n \\"id\\": 123,\\n \\"name\\": \\"******\\"}"

    iex> JsonScrub.scrub_json("it doesnt have to be .json but it wont scrub anything")
    "it doesnt have to be .json but it wont scrub anything"

  """
  @spec scrub_json(binary, map | list | binary | atom) :: binary
  def scrub_json(file, key \\ ["name", "username", "password", "email"]) do
    scrub(file, key)
  end

  defp scrub(_, []), do: IO.puts("key cannot be an empty list")
  defp scrub(_, nil), do: IO.puts("key cannot be nil")

  defp scrub(file, key) when is_map(key) do
    scrub(
      file,
      Map.values(key)
    )
  end

  defp scrub(file, [head | []] = key) when is_list(key) do
    key_is_email?(file, head)
  end

  defp scrub(file, [head | tail] = key) when is_list(key) do
    key_is_email?(file, head)
    |> scrub(tail)
  end

  defp scrub(file, key) do
    replace(file, key)
  end

  # if key is "email" then replace uses different regex
  defp key_is_email?(file, key) when is_atom(key) do
    Atom.to_string(key)
    |> String.downcase()
    |> replace(file)
  end

  defp key_is_email?(file, key) when is_binary(key) do
    String.downcase(key)
    |> replace(file)
  end

  # the 'i' on the email regex means that the key "email" is case insensitive
  # the .json key could be "EmAiL" and it will still obscure appropriately
  # even if the default "email" key was passed
  defp replace(key, file) do
    case key do
      "email" ->
        # email regex - (\"<email key>\":) whitespace to next \" (<email value>)(until @)
        String.replace(file, ~r{(\"#{key}\":)\s*\"(.+?)(?=@)}iu, "\\g{1} \"******")

      _ ->
        # all other regex - (\"<key>\":) whitespace to next \" (<value>)(until next \")
        String.replace(file, ~r{(\"#{key}\":)\s*\"(.+?)(?=\")}iu, "\\g{1} \"******")
    end
  end
end
