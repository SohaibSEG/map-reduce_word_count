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
    reducer_pid = spawn_link(Reducer, :wait, [self()])

    file_paths(directory)
      |> Enum.map(fn file_path ->
        {pid, _} = spawn_monitor(Mapper, :map, [file_path, reducer_pid, self()])
        pid
      end) |> wait_for_mappers()

    # After confirming all mappers are done, stop the reducer
    send(reducer_pid, :stop)
    receive_reduced_data()
  end

  defp wait_for_mappers([]) do
    IO.puts("All mappers done")
  end

  defp wait_for_mappers(pids) do
    receive do
      {:mapper_done, pid} ->
        IO.puts("Mapper done: #{inspect(pid)}")
        wait_for_mappers(List.delete(pids, pid))

      {:DOWN, _, :process, pid, {%RuntimeError{} = error, _stacktrace}} ->
        IO.puts("Mapper failed: #{inspect(pid)} with error: #{inspect(error)}")
        wait_for_mappers(List.delete(pids, pid))
    end
  end

  defp receive_reduced_data() do
    receive do
      {:reduced, data} ->
        IO.inspect(data, label: "Final word count")
    end
  end

  defp file_paths(directory) do
    Path.wildcard(Path.join(directory, "*"))
  end
end
