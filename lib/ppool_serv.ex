defmodule PpoolServ do
  use GenServer

  defmodule State do
    defstruct limit: 0, sup: nil, refs: nil, queue: :queue.new
  end

  def start_link(name, limit, sup, mfa) when is_atom(name) and is_integer(limit) do
    IO.puts "Starting #{__MODULE__} #{inspect self}"
    GenServer.start_link(__MODULE__, {limit, mfa, sup}, name: name)
  end

  def run(name, args) do
    IO.puts "#{inspect args}"
    GenServer.call(name, {:run, args})
  end

  def sync_queue(name, args) do
    GenServer.call(name, {:sync, args}, :infinity)
  end

  def async_queue(name, args) do
    GenServer.cast(name, {:async, args})
  end

  def stop(name) do
    GenServer.call(name, :stop)
  end

  defp supervisor_spec(mfa) do
    opts = [shutdown: 10000]
    Supervisor.supervise([Supervisor.supervisor(PpoolWorkerSup, [mfa], opts)], [shutdown: :temporary])
  end

  def handle_call({:run, args}, _from, s = %State{limit: n, sup: sup, refs: refs}) when n > 0 do
    IO.puts "Starting child with #{inspect args}"
    {:ok, pid} = Supervisor.start_child(sup, args)
    ref = Process.monitor(pid)
    {:reply, {:ok, pid}, %{s | limit: n-1, refs: :gb_sets.add(refs, ref)}}
  end

  def handle_call({:run, _args}, _from, s = %State{limit: n}) when n <= 0 do
    {:reply, :noalloc, s}
  end

  def handle_call({:sync, args}, _from, s = %State{limit: n, sup: sup, refs: r}) when n > 0 do
    {:ok, pid} = Supervisor.start_child(sup, args)
    ref = Process.monitor(pid)
    {:reply, {:ok, pid}, %{s | limit: n-1, refs: :gb_sets.add(ref, r)}}
  end

  def handle_call({:sync, args}, from, s = %State{queue: q}) do
    {:noreply, %{s | queue: :queue.in({from, args}, q)}}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call(_msg, _from, state) do
    {:noreply, state}
  end

  def handle_cast({:async, args}, s = %State{limit: n, sup: sup, refs: r}) when n > 0 do
    {:ok, pid} = Supervisor.start_child(sup, args)
    ref = Process.monitor(pid)
    {:noreply, %{s | limit: n-1, refs: :gb_sets.add(ref, r)}}
  end

  def handle_cast({:async, args}, s = %State{queue: q}) do
    {:noreply, %{s | queue: :queue.in(args, q)}}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _}, s = %State{refs: refs}) do
    IO.puts "Received down message"
    case :gb_sets.is_element(ref, refs) do
      true ->
        handle_down_worker(ref, s)
      false ->
        {:no_reply, s}
    end
  end

  def handle_info({:start_worker_supervisor, sup, mfa}, s = %State{}) do
    {:ok, pid} = Supervisor.start_child(sup, supervisor_spec(mfa))
    {:noreply, %{s | sup: pid}}
  end

  def handle_info(msg, state) do
    IO.puts "Unknown message: #{msg}"
    {:noreply, state}
  end

  def handle_down_worker(ref, s = %State{limit: l, sup: sup, refs: refs}) do
    case :queue.out(s.queue) do
      {{:value, {from, args}}, q} ->
        {:ok, pid} = Supervisor.start_child(sup, args)
        new_ref = Process.monitor(pid)
        new_refs = :gb_sets.insert(new_ref, :gb_sets.delete(ref, refs))
        GenServer.reply(from, {:ok, pid})
        {:noreply, %{s | refs: new_refs, queue: q}}

      {{:value, args}, q} ->
        {:ok, pid} = Supervisor.start_child(sup, args)
        new_ref = Process.monitor(pid)
        new_refs = :gb_sets.insert(new_ref, :gb_sets.delete(ref, refs))
        {:noreply, %{s | refs: new_refs, queue: q}}

      {:empty, _} ->
        {:noreply, %{s | limit: l+1, refs: :gb_sets.delete(ref, refs)}}
    end
  end

end
