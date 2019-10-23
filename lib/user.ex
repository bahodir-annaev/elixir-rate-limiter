defmodule User do
  def send_msg(pid, from, counter) do
    counter = counter + 1
    RateLimiter.send_message(pid, "message #{counter} from #{inspect(from)}")
    send_msg(pid, from, counter)
  end

  def run do
    {:ok, pid} = RateLimiter.start(name: Limiter)
    Enum.each(1..100, fn n -> spawn(fn -> send_msg(pid, n, 0) end) end)
  end
end
