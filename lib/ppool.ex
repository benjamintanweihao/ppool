defmodule Ppool do

  def start_link do
    PpoolSupersup.start_link
  end

  def stop do
    PpoolSupersup.stop
  end

  def start_pool(name, limit, {m,f,a}) do
    PpoolSupersup.start_pool(name, limit, {m,f,a})
  end

  def stop(name) do
    PpoolSupersup.stop_pool(name)
  end

  # TODO: What does this do?
  def run(name, args) do
    PpoolServ.run(name, args)
  end

  def sync_queue(name, args) do
    PpoolServ.sync_queue(name, args)
  end

  def async_queue(name, args) do
    PpoolServ.async_queue(name, args)
  end

end
