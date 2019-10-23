defmodule RateLimiter do

  use GenServer

  def start([name: name]) do
    GenServer.start_link(__MODULE__, name: name)
  end

  def send_message(pid, message) do
    {:message_queue_len, count} = Process.info(pid, :message_queue_len)
    IO.puts "Unread messages #{count}"
    # here is the logic for back pressure
    case count < 1000 do
      true -> GenServer.cast(pid, {:msg, message})
      false -> GenServer.call(pid, {:msg, message}, :infinity)
    end
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:msg, message}, from, state) do
    process_message(message, 1000)
    {:reply, from, state}
  end

  def handle_cast({:msg, message}, state) do
    process_message(message, 1000)
    {:noreply, state}
  end

  def handle_info({:msg, message}, state) do
    process_message(message, 1000)
    {:noreply, state}
  end

  defp process_message(message, timeout) do
    :timer.sleep(timeout)
    IO.puts message
  end
end
