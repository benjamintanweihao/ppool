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

  def stop_pool(name) do
    PpoolSupersup.stop_pool(name)
  end

  def run(name, args) do
    PpoolServ.run(name, args)
  end

  def sync_queue(name, args) do
    PpoolServ.sync_queue(name, args)
  end

  def async_queue(name, args) do
    PpoolServ.async_queue(name, args)
  end

  # TODO: REMOVE LATER
  def run do
    Ppool.start_link
    Ppool.start_pool(:nagger, 2, {PpoolNagger, :start, []})
    Ppool.run(:nagger, ["finish the chapter!", 5000, 2, self])
    Ppool.run(:nagger, ["Watch a good movie", 5000, 2, self])
  end

end
