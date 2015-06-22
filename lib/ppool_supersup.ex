defmodule PpoolSupersup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    opts = [strategy: :one_for_one,
            max_restart: 6,
            max_time: 3600]

    supervise([], opts)
  end

  def start_pool(name, limit, mfa) do
    # NOTE: Show what the default values are.
    #       Compare them with Erlang.
    child_spec = supervisor(PpoolSup, [name, limit, mfa])
    Supervisor.start_child(__MODULE__, child_spec)
  end

  def stop_pool(name) do
    Supervisor.terminate_child(__MODULE__, name)
    Supervisor.delete_child(__MODULE__, name)
  end

  def stop do
    case Process.whereis(__MODULE__) do
      pid when is_pid(pid) ->
        Process.exit(pid, :kill)
      _ ->
        :ok
    end
  end
end
