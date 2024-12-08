
# WordCount Elixir

An over-engineered Elixir-based word count map-reduce application that reads text files from a directory, maps the words, and then reduces the counts using multiple processes. This project demonstrates key Elixir features such as concurrency, message passing, and process management.

## Features
- **Concurrency with Processes**: Mapper and Reducer processes are spawned for each file, allowing for parallel computation.
- **Message Passing**: Communication between processes using Elixir’s `send` and `receive` mechanisms.
- **Functional Programming**: The project makes use of higher-order functions and pattern matching to process data.
- **Immutable State**: The word counts are accumulated in an immutable map, ensuring no side effects.
- **Directory Handling**: Files are read from a specified directory using path wildcards.

## Language Features Demonstrated

### 1. **Processes and Concurrency**
   Elixir is a concurrent language built on the Erlang virtual machine (BEAM). In this project, processes are used to perform mapping and reducing tasks in parallel.

   - **Spawning Processes**: 
     ```elixir
     reducer_pid = spawn(Reducer, :wait, [self()])
     ```
     The `spawn/3` function is used to create processes for the `Mapper` and `Reducer` modules.

   - **Message Passing**: 
     ```elixir
     send(reducer_pid, {:reduce, m})
     ```
     Elixir's `send` and `receive` allow for message passing between processes. This is used to send the word mapping results to the reducer and retrieve the final word count.

### 2. **Pattern Matching**
   Pattern matching is a powerful feature in Elixir that allows you to match and destructure data efficiently. This is used extensively in both the mapping and reducing phases.

   - **Matching with Tuples**:
     ```elixir
     {:ok, content} = File.read(file_path)
     ```
     In the `count` function, `{:ok, content}` is used to handle the result of reading files.

   - **Matching on `receive`**:
     ```elixir
     receive do
       {:reduced, data} -> IO.inspect(data, label: "Final word count")
     end
     ```
     The `receive` block matches messages sent to the process and executes code accordingly.

### 3. **Higher-Order Functions**
   Elixir makes heavy use of higher-order functions, where functions can be passed around and used as arguments.

   - **Enum and List Manipulation**:
     ```elixir
     file_paths(directory)
     |> Enum.each(fn file_path -> spawn(Mapper, :map, [file_path, reducer_pid, self()]) end)
     ```
     The `Enum` module provides functions to work with collections, such as `Enum.each/2` for iteration and `Enum.count/1` for counting elements.

### 4. **Immutability**
   In Elixir, data is immutable by default, meaning that once a value is assigned, it cannot be changed. This feature is essential for building reliable concurrent systems.

   - **Immutable Maps**:
     ```elixir
     Map.update(acc, k, v, &(&1 + v))
     ```
     The `acc` map used in the reducer process accumulates word counts immutably, avoiding side effects.

### 5. **File and Directory Management**
   Elixir's `Path` and `File` modules are used to handle file reading and writing, as well as to work with file paths.

   - **Path Wildcards**:
     ```elixir
     Path.wildcard(Path.join(directory, "*.txt"))
     ```
     This allows the application to dynamically list all text files in a specified directory, making it flexible and adaptable to different input datasets.

### 6. **Recursion and Tail Call Optimization**
   Elixir uses tail recursion for handling loops and repeated tasks. This is especially useful for processes that need to wait for messages (such as the reducer process).

   - **Tail Recursion in `wait_for_mappers/1`**:
     ```elixir
     defp wait_for_mappers(remaining) when remaining > 0 do
       receive do
         {:mapper_done, pid} ->
           IO.puts("Mapper done: #{inspect(pid)}")
           wait_for_mappers(remaining - 1)
       end
     end
     ```

## Installation

1. Install Elixir by following the instructions on the [official Elixir website](https://elixir-lang.org/install.html).
2. Clone this repository:
   ```bash
   git clone https://github.com/your-username/wordcount-elixir.git
   cd wordcount-elixir
   ```
3. Run the application using IEx (Interactive Elixir):
   ```bash
   iex -S mix
   ```

## Usage

To count words in text files within a specific directory, simply call the `WordCount.count/1` function and pass the directory path:

```elixir
WordCount.count("path/to/your/text/files")
```

The program will process the files, map the words, reduce the counts, and print the final word count.

