Ppool - A direct port of LYSE Chapter 18 in Elixir
==================================================


```elixir
Ppool.start_pool(:nagger, 2, {PpoolNagger, :start_link, []})
```

### Why is it that we can pass in an empty list to `:start_link` when `PpoolNagger.start_link/4` takes in 4 arguments?

From Robert Virding:

> ... Also in this case the second argument to supervisor:start_child/2 must be a list and NOT a ChildSpec. This list is a list of extra arguments which is appended to the argument list given in the default ChildSpec and it is this combined argument list which is used when calling the child's start function. This is how the simple_one_for_one children all can use the same ChildSpec and still can get in specific arguments to them.

```
Ppool.run(:nagger, ["Go home", 5000, 2, self])
```

```
Ppool.sync_queue(:nagger, ["Go home", 5000, 2, self])
Ppool.async_queue(:nagger, ["Go home", 5000, 2, self])
```

```
Ppool.stop(:nagger)
```

