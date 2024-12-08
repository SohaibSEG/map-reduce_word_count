defmodule Generator do
  @moduledoc """
  A module for generating text files with predefined content.
  """

  @sample_text """
  The market bustled with life. Vendors shouted, selling fresh apples, ripe oranges, and sweet grapes. Children ran through the crowd, laughing, while dogs barked at the commotion.
  An old woman sold fragrant lavender, its scent drifting on the breeze. Near the fountain, a young boy named Tom held a basket of bright red apples, calling to villagers:
  “Fresh apples! Juicy apples!” His family’s orchard was famous for its fruit. A group of curious children gathered, asking for tales about the old tree in the forest,
  rumored to grow golden fruit. Tom smiled and began the story.
  """

  @doc """
  Generates a specified number of text files, each containing a specified number of lines of content.

  ## Parameters

    - `num_files`: The number of files to generate.
    - `lines_per_file`: The number of lines of content each file should contain.
    - `directory`: (Optional) The directory where the files will be saved. Defaults to "data".

  ## Examples

      iex> Generator.generate_files(3, 5)
      Generated: data/file_1.txt
      Generated: data/file_2.txt
      Generated: data/file_3.txt

  """
  def generate_files(num_files, lines_per_file, directory \\ "data") do
    ensure_directory_exists(directory)

    for i <- 1..num_files do
      file_path = Path.join(directory, "file_#{i}.txt")
      content = generate_content(lines_per_file)
      File.write!(file_path, content)
      IO.puts("Generated: #{file_path}")
    end
  end

  @doc false
  defp ensure_directory_exists(directory) do
    unless File.dir?(directory) do
      File.mkdir_p!(directory)
      IO.puts("Created directory: #{directory}")
    end
  end

  @doc false
  defp generate_content(lines) do
    # Repeat the sample text to fill the required number of lines
    Enum.map_join(1..lines, "\n", fn _ -> @sample_text end)
  end
end
