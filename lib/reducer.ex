defmodule Reducer do
  @moduledoc """
  A module for reducing word-count data, accumulating the counts for each word,
  and sending the final result back to the parent process when requested.
  """

  @doc """
  Reduces a list of word-count tuples by accumulating counts for each word.

  The `reduce/2` function takes an accumulator and a list of word-count tuples,
  and applies `count_words/2` to combine the word counts into a single map.

  ## Parameters

    - `acc` (Map.t): The accumulator, which is a map that holds the cumulative word counts.
    - `data` (List.t): A list of word-count tuples, where each tuple is in the form `{word, count}`.

  ## Returns

    - The updated accumulator map with the accumulated word counts.

  ## Examples

      iex> Reducer.reduce(%{}, [{"apple", 1}, {"banana", 1}, {"apple", 1}])
      %{"apple" => 2, "banana" => 1}

  """
  def reduce(acc, data) do
    data |> Enum.reduce(acc, &count_words/2)
  end

  @doc false
  defp count_words({word, count}, acc) do
    Map.update(acc, word, count, &(&1 + count))
  end

  @doc """
  Waits for messages and processes them in the context of word-count reduction.

  This function listens for two types of messages:
    - `{:reduce, data}`: Processes the word-count data and adds it to the accumulator.
    - `:stop`: Finalizes the reduction, stops the process, and sends the result back to the parent process.
    - Any other message is logged as an unknown message.

  ## Parameters

    - `parent_pid` (pid): The PID of the parent process to send the final result to when finished.
    - `acc` (Map.t, optional): The accumulator that holds the word counts. Defaults to an empty map.

  ## Examples

      iex> Reducer.wait(parent_pid)
      # Starts waiting for messages and processes the data accordingly.

  """
  def wait(parent_pid, acc \\ %{}) do
    receive do
      {:reduce, data} ->
        acc = reduce(acc, data)
        wait(parent_pid, acc)

      :stop ->
        IO.puts("Reducer stopped")
        send(parent_pid, {:reduced, acc})

      _ ->
        IO.puts("Reducer received unknown message")
        wait(parent_pid, acc)
    end
  end
end
