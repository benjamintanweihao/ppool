defmodule PpoolWorkerSup do
  use Supervisor

  # NOTE: ehh ... which direction ah.
  def start_link(mfa = {_,_,_}) do
    IO.puts "Starting #{__MODULE__} #{inspect self}"
    Supervisor.start_link(__MODULE__, mfa)
  end

  def init({m,f,a}) do
    opts = [strategy: :simple_one_for_one,
            max_restart: 5,
            max_time: 3600]

    worker_opts = [restart: :temporary,
                   shutdown: 5000]
    children = [worker(PpoolWorker, [{m,f,a}], worker_opts)]

    supervise(children, opts)
  end
end
