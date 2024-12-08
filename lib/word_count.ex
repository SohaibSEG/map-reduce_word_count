defmodule WordCount do
  @doc """
  Counts the occurrences of words in the text files located in the specified directory.

  This function performs the following steps:
    1. Spawns the reducer process.
    2. Reads the text files from the specified directory.
    3. Spawns mapper processes for each file.
    4. Waits for all mappers to complete.
    5. Requests the final reduced word counts from the reducer.

  ## Parameters
    - `directory` (String): The directory path containing the text files to be processed.

  ## Examples

      iex> WordCount.count("data")
      "Mapping: data/file_1.txt"
      "Mapper done: #PID<0.123.0>"
      "All mappers done"
      "Final word count: %{\"word1\" => 5, \"word2\" => 2}"

  """
  def count(directory) do
    reducer_pid = spawn(Reducer, :wait, [self()])

    file_paths(directory)
    |> Enum.map(fn file_path ->
      spawn(Mapper, :map, [file_path, reducer_pid, self()])
    end)
    |> Enum.count()
    |> wait_for_mappers()

    # After all mappers are done, stop the reducer and get the final word count
    receive_reduced_data(reducer_pid)
  end


  defp wait_for_mappers(remaining) when remaining > 0 do
    receive do
      {:mapper_done, pid} ->
        IO.puts("Mapper done: #{inspect(pid)}")
        wait_for_mappers(remaining - 1)
    end
  end

  defp wait_for_mappers(0) do
    IO.puts("All mappers done")
  end
  defp receive_reduced_data(reducer_pid) do
    send(reducer_pid, :stop)

    receive do
      {:reduced, data} -> IO.inspect(data, label: "Final word count")
    end
  end

  defp file_paths(directory) do
    Path.wildcard(Path.join(directory, "*"))
  end
end
