using ProgressBars

function load_data(path)
  f = open(path)
  data = readlines(f)
  close(f)
  return permutedims(stack(collect.(data)))
end

data = load_data("day16.csv")

direction_mapper = Dict{Char, Dict{Array, Array}}(
  '.' => Dict(),
  '-' => Dict([1, 0] => [[0, -1], [0, 1]], [-1, 0] => [[0, -1], [0, 1]]),
  '|' => Dict([0, 1] => [[-1, 0], [1, 0]], [0, -1] => [[-1, 0], [1, 0]]),
  '/' => Dict([0, 1] => [[-1, 0]], [1, 0] => [[0, -1]], [0, -1] => [[1, 0]], [-1, 0] => [[0, 1]]),
  '\\' => Dict([0, 1] => [[1, 0]], [1, 0] => [[0, 1]], [0, -1] => [[-1, 0]], [-1, 0] => [[0, -1]]) )

function check_range(p)
  return (p[1] >= 1) && (p[1] <= size(data, 1)) && (p[2] >= 1) && (p[2] <= size(data, 2))
end

top = [[1, x] for x in range(1, size(data, 2))]
dtop = [1, 0]
bottom = [[size(data, 1), x] for x in range(1, size(data, 2))]
dbottom = [-1, 0]
left = [[x, 1] for x in range(1, size(data, 1))]
dleft = [0, 1]
right = [[x, size(data, 2)] for x in range(1, size(data, 1))]
dright = [0, -1]

start_top = [[x, dtop] for x in top]
start_bottom = [[x, dbottom] for x in bottom]
start_left = [[x, dleft] for x in left]
start_right = [[x, dright] for x in right]

start = vcat(start_top, start_bottom, start_left, start_right)
max_energy = -1
for (p0, d0) in ProgressBar(start)
  rays = [[p0, d0]]
  energy = zeros(Bool, size(data))
  energy[rays[1][1]...] += true
  p_energy = 0
  historic_rays = Set{Vector}(rays)
  while length(rays) > 0
    p, d = popfirst!(rays)
    new_directions = get(direction_mapper[data[p...]], d, [d])
    new_rays = Vector{Any}()
    for new_d in new_directions
      new_p = p .+ new_d
      if check_range(new_p)
        push!(new_rays, [new_p, new_d])
        energy[new_p...] = true
      end
    end
    for ray in setdiff(new_rays, historic_rays)
      push!(rays, ray)
    end
    push!(historic_rays, [p, d])
  end
  max_energy = max(max_energy, count(energy))
end


max_energy
