using Debugger

function load_data(path)
  f = open(path)
  data = readlines(f)
  close(f)
  return parse.(Ref(Int), permutedims(stack(collect.(data))))
end

data = load_data("day17.csv")
min_steps = 4 # -1 or 4 according to part 1 or 2.
max_steps = 10 # 3 or 10 according to part 1 or 2.
graph = Array{Int}(undef, size(data)..., 4, max_steps)
for idx in Iterators.product(range(1, 4), range(1, max_steps))
  graph[:, :, idx...] .= data
end

direction = Dict{Vector{Int}, Int}(
  [1, 0] => 1,
  [0, 1] => 2,
  [-1, 0] => 3,
  [0, -1] => 4)

inverse_direction = Dict{Int, Vector{Int}}(
  1 => [1, 0],
  2 => [0, 1],
  3 => [-1, 0],
  4 => [0, -1])

# (coordinates..., direction, steps)
function compute_neighbors(node, s1, s2)
  """
  Compute neighbors of node in size (s1, s2).
  """
  new_nodes = []
  n_direction = []
  if node[4] < min_steps # Comment this for part 1.
    n_direction = [ inverse_direction[node[3]] ]
    n_node = node + CartesianIndex(n_direction[1]..., 0, 1)
    if (1 <= n_node[1] <= s1) || !(1 <= n_node[2] <= s2)
      new_nodes = [ n_node ]
    else
      n_direction = []
    end
  else
    l1 = max(1, node[1] - 1)
    u1 = min(s1, node[1] + 1)
    l2 = max(1, node[2] - 1)
    u2 = min(s2, node[2] + 1)
    iter = Iterators.product(range(l1, u1), range(l2, u2))
    to_compare = mod(node[1] + node[2], 2)
    neighbors = [collect(x) for x in iter if mod(sum(x), 2) != to_compare]
    n_direction = [x - [node[1], node[2]] for x in neighbors]
    new_direction = [direction[x] for x in n_direction]
    new_steps = [d == node[3] ? node[4] + 1 : 1 for d in new_direction]
    new_nodes = [CartesianIndex(n..., d, s) for (n, d, s) in zip(neighbors, new_direction, new_steps) if s <= max_steps]
  end
  remaining = min_steps .- [n[4] for n in new_nodes]
  final_step = [[n[1], n[2]] + (r .* d) for (n, r, d) in zip(new_nodes, remaining, n_direction)]
  return [n for (n, f) in zip(new_nodes, final_step) if all( 1 .<= f .<= [s1, s2] )]
end

function apply_dijkstra(graph)
  s1, s2 = size(graph)[1:2]
  unvisited = ones(Bool, size(graph))
  mask = reshape(findall(ones(Bool, size(graph))), size(graph))
  paths = Array{Any}(undef, size(graph))
  dist = Inf * ones(Int, size(graph))
  starting = CartesianIndex(2, 1, 1, 1)
  paths[starting] = [[starting[1], starting[2]]]
  dist[starting] = graph[starting]
  starting = CartesianIndex(1, 2, 2, 1)
  paths[starting] = [[starting[1], starting[2]]]
  dist[starting] = graph[starting]
  counter = 0
  while all( unvisited[end, end, :, :] )
    if mod(counter, 100) == 0
      println(counter)
    end
    current = mask[unvisited][argmin(dist[unvisited])]
    neighbors = compute_neighbors(current, s1, s2)
    neighbors = neighbors[unvisited[neighbors]]
    weights = [graph[n] for n in neighbors] .+ dist[current]
    improved = weights .<= dist[neighbors]
    for (j, n) in enumerate(neighbors)
      if !improved[j]
        continue
      end
      new_node = [n[1], n[2]]
      if new_node in paths[current]
        continue
      end
      dist[n] = min(weights[j], dist[n])
      paths[n] = [paths[current]..., new_node]
    end
    unvisited[current] = false
    counter += 1
  end
  return (dist, paths)
end

dist, paths = apply_dijkstra(graph);

results = dist[end, end, :, :]
chosen_path = paths[end, end, argmin(results)]
path = [CartesianIndex(c...) for c in chosen_path]
draw = zeros(Bool, size(data))
draw[path] .= true
draw

minimum(results)
