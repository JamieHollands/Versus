defmodule JsonScrubHelpers do
  @moduledoc """
  Contains helps to open and write .json files
  """

  @doc """
  Opens a .json file with a string/binary that points to its location

  Returns {:ok, file} | {:error, "not a .json file} | {:error, :enoent}

  ## Examples

    iex> JsonScrubHelpers.open_file("./test_files/not_a_json_file.js")
    {:error, "must be a .json file"}

    iex> JsonScrubHelpers.open_file("./test_files/not_a_real_file.json")
    {:error, :enoent}

    iex> JsonScrubHelpers.open_file("./test_files/json_scrub_test.json")
    ...> {:ok, "{\\n    \\"name\\": \\"test\\",\\n    \\"username\\": \\"jsonscrubtest\\",\\n
    ...> \\"EmAiL\\": \\"test@jsonscrubtest.com\\",\\n    \\"password\\": \\"secretpassword\\"\\n}" }


  """
  @spec open_file(binary) :: {:error, atom} | {:ok, any}
  def open_file(file_name) when is_binary(file_name) do
    case is_json?(file_name) do
      {:error, reason} ->
        {:error, reason}

      {:ok, file_name} ->
        case File.open(file_name, [:read], fn file ->
               IO.read(file, :eof)
             end) do
          {:ok, file} ->
            {:ok, file}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  def open_file(_file_name), do: {:error, "file name must be a binary"}

  # checks for a .json file extension
  defp is_json?(file_name) do
    case Path.extname(file_name) do
      ".json" ->
        {:ok, file_name}

      _ ->
        {:error, "must be a .json file"}
    end
  end
end
