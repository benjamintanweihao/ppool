defmodule SampleWorker do
  use GenServer

  def start_link do
    IO.puts "#{__MODULE__} starting ..."
    GenServer.start_link(__MODULE__, [])
  end

  def handle_call(:compute, from, []) do
    :timer.sleep(10000)
    send(from, "ohai!!!")
    {:reply, :ok, []}
  end

  def handle_cast(:compute, []) do
    :timer.sleep(10000)
    {:noreply, :ok}
  end
end
