using UnicodePlots
using Debugger
using ProgressBars

direction_mapper = Dict{Char, Vector{Int}}(
  'U' => [-1, 0],
  'R' => [0, 1],
  'D' => [1, 0],
  'L' => [0, -1])

function load_data(path)
  f = open(path)
  data = split.(readlines(f))
  close(f)
  directions = [only(d[1]) for d in data]
  steps = [parse(Int, d[2]) for d in data]
  return directions, steps
end
directions, steps = load_data("day18.csv")

function load_data_2(path)
  f = open(path)
  data = split.(readlines(f))
  close(f)
  direction_mapper = Dict(0 => 'R', 1 => 'D', 2 => 'L', 3 => 'U')
  colors = [collect(d[3])[3:end-1] for d in data]
  steps = [parse(Int, join(c[1:end-1]), base = 16) for c in colors]
  directions = [direction_mapper[parse(Int, c[end])] for c in colors]
  return directions, steps
end
directions, steps = load_data_2("day18.csv")


## Inneficcient version for part 1.
len = 1 + sum(steps)
path = Array{CartesianIndex{2}}(undef, len)
path[1] = CartesianIndex(1, 1)
counter = 1
for (d, s) in ProgressBar(zip(directions, steps))
  to_add = CartesianIndex(direction_mapper[d]...)
  for j in range(1, s)
    path[counter + 1] = path[counter] + to_add
    counter += 1
  end
end

old_mask = zeros(Bool, (10, 7))
old_mask[old_loop] .= true

r1 = minimum([x[1] for x in path])
r2 = minimum([x[2] for x in path])
path = [p - CartesianIndex(r1 - 1, r2 - 1) for p in path]

R1 = maximum([x[1] for x in path])
R2 = maximum([x[2] for x in path])
old_mask = zeros(Bool, (R1, R2))
old_mask[path] .= true
mask = zeros(Bool, (R1 + 2, R2 + 2))
mask[2:end-1, 2:end-1] .= old_mask

function get_neighbors(node, s1, s2)
  l1 = max(1, node[1] - 1)
  u1 = min(s1, node[1] + 1)
  l2 = max(1, node[2] - 1)
  u2 = min(s2, node[2] + 1)
  new_nodes = [CartesianIndex(x) for x in Iterators.product(range(l1, u1), range(l2, u2))]
  return new_nodes
end

interior = zeros(Bool, size(mask))
s1, s2 = size(interior)
route = [CartesianIndex(401, 251)]
for j in ProgressBar(range(1, s1 * s2))
  if length(route) == 0
    break
  end
  current = pop!(route)
  interior[current] = true
  new_nodes = get_neighbors(current, s1, s2)
  new_nodes = new_nodes[.!(interior[new_nodes])]
  new_nodes = new_nodes[.!(mask[new_nodes])]
  interior[new_nodes] .= true
  route = [route..., new_nodes...]
end

## Efficient version for part 2.
len = 1 + length(steps);
loop = Array{CartesianIndex{2}}(undef, len);
loop[1] = CartesianIndex(1, 1);
for it in ProgressBar(enumerate(zip(directions, steps)))
  j = it[1]
  d, s = it[2]
  loop[j + 1] = loop[j] + s * CartesianIndex(direction_mapper[d]...)
end

x = collect(range(0, length(loop) - 1))
loop_array = [[s[2], -s[1]] for s in loop]
path = loop_array[2:end]
dloop = diff(loop_array)
area = abs(sum([x[2]*dx[1] - x[1]*dx[2] for (x, dx) in zip(path, dloop)]) / 2)
angles = (1 / 2) * sum(steps) - 2
n_interior = area - angles - 1

Int(n_interior + sum(steps))
