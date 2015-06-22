defmodule PpoolSup do
  use Supervisor

  def start_link(name, limit, mfa) do
    Supervisor.start_link(__MODULE__, {name, limit, mfa})
  end

  def init ({name, limit, mfa}) do
    opts = [strategy: :one_for_all,
            max_restart: 1,
            max_time: 3600]

    worker_opts = [
      shutdown: 5000
    ]

    # NOTE: Pass self here, so that the server can
    #       use the Supervisor pid
    children = [
      worker(PpoolServ, [name, limit, self, mfa], worker_opts)
    ]

    supervise(children, opts)
   end
end
