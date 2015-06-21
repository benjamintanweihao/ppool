defmodule PpoolTest do
  use ExUnit.Case

  test "a sample run" do
    {:ok, _pid} = Ppool.start_link
    Ppool.start_pool(:sample, 2, {SampleWorker, :start_link, []})


  end
end
