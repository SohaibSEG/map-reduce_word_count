defmodule Mapper do
  @moduledoc """
  A module for processing text files, mapping their content into word counts,
  and sending the data to a reducer process for further processing.
  """

  @doc """
  Reads the content of a file, processes it into a list of word-count tuples,
  and sends the result to a reducer process.

  After processing, notifies the parent process that the mapper is done.

  ## Parameters

    - `file_path` (String.t): The path to the file to be processed.
    - `reducer_pid` (pid): The PID of the reducer process to send the mapped data to.
    - `parent_pid` (pid): The PID of the parent process to notify when the mapper is done.

  ## Behavior

    1. Reads the file specified by `file_path`.
    2. Processes the file content:
        - Splits the content into words.
        - Converts words to lowercase.
        - Removes non-alphabetic characters.
        - Filters out empty strings.
        - Maps each word to a tuple `{word, 1}`.
    3. Sends the processed list of word-count tuples to the reducer process.
    4. Notifies the parent process that the mapper has completed its work.

  ## Messages Sent

    - To the reducer process: `{:reduce, mapped_data}`
      where `mapped_data` is a list of word-count tuples.
    - To the parent process: `{:mapper_done, mapper_pid}`
      where `mapper_pid` is the PID of the mapper process.

  ## Examples

      iex> Mapper.map("data/file_1.txt", reducer_pid, parent_pid)
      # This will process the file, send data to the reducer, and notify the parent.

  ## Error Handling

  If the file cannot be read, it logs the error and sends only the
  `{:mapper_done, self()}` message to the parent process.

  """
  def map(file_path, reducer_pid, parent_pid) do
    # simulate Randomly crashing the process with a probability of 1/100
    if :rand.uniform(100) == 1 do
      raise "Random crash in Mapper #{inspect(self())}"
    end
    case File.read(file_path) do
      {:ok, content} ->
        IO.puts("Mapping: #{file_path}")
        # Process file content into word counts
        String.split(content, ~r/\W+/)
        |> Enum.map(&String.downcase/1)
        |> Enum.map(&String.replace(&1, ~r/[^a-z]/, ""))
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&{&1, 1})
        |> then(fn mapped_data -> send(reducer_pid, {:reduce, mapped_data}) end)

      {:error, reason} ->
        IO.puts("Failed to open #{file_path}: #{reason}")
        # Handle file read error gracefully
        []
    end

    # Notify parent process that this mapper is done
    send(parent_pid, {:mapper_done, self()})
  end
end
