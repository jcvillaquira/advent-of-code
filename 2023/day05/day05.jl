## Open file.
f = open("day05.csv")
data = readlines(f)
close(f)

# Part 1.
## Load seeds.
seeds_p1 = [parse(Int, x) for x in split(data[1])[2:end]]
seeds_p2 = Array{Any}(undef, 0)
for (j, s) in enumerate(seeds_p1)
  if mod(j, 2) == 0
    continue
  end
  ss = seeds_p1[j + 1]
  push!(seeds_p2, (s, s+ss-1))
end

map_index = Array{Int}(undef, 0)
for (j, l) in enumerate(data)
  if l == ""
    push!(map_index, j)
  end
end
push!(map_index, length(data) + 1)

## Get arrays.
maps = Array{Any}(undef, 0)
for j in range(1, length(map_index) - 1)
  m0 = map_index[j] + 2
  m1 = map_index[j + 1] - 1
  to_add = [split(x) for x in data[m0:m1]]
  push!(maps, parse.(Ref(Int), permutedims(stack(to_add))) )
end

function create_function(map_array)
  to_return = Dict()
  for j in range(1, size(map_array, 1))
    destination, source, len = map_array[j, :]
    domain = range(source, source + len - 1)
    map_domain = x -> destination + ( x - source )
    to_return[domain] = map_domain
  end
  return to_return
end

function evaluate_step(layer, seed)
  for domain in keys(layer)
    if seed in domain
      return layer[domain](seed)
    end
  end
  return seed
end

mappers = create_function.(maps)

# Part 2.
endpoints = [[(k[1], k[end]) for k in keys(m)] for m in mappers]
endpoints = [sort(e, by = x -> x[1]) for e in endpoints]
endpoints = [[(-Inf, e[1][1]-1), e..., (e[end][end]+1, Inf)] for e in endpoints]
function fill_endpoints(intervals)
  to_return = [k for k in intervals]
  for j in range(1, length(intervals) - 1)
    sup = intervals[j][end]
    inf = intervals[j+1][1]
    if sup + 1 < inf
      push!(to_return, (sup + 1, inf - 1))
    end
  end
  return sort(to_return, by = x -> x[1])
end
endpoints = fill_endpoints.(endpoints)

function compute_bias(interval, mapper)
  if (interval[1] == -Inf) || (interval[end] == Inf)
    return 0
  end
  return evaluate_step(mapper, interval[1]) - interval[1]
end

function compose_all(x, mappers)
  for m in mappers
    x = evaluate_step(m, x)
  end
  return x
end

biases = [compute_bias.(e, Ref(m)) for (e, m) in zip(endpoints, mappers)]

function pull_back(previous, bias, actual)
  push_forward = [(x -> x + b).(i) for (i, b) in zip(previous, bias)]
  new_previous = Array{Any}(undef, 0)
  for (i, b) in zip(push_forward, bias)
    to_add = Set()
    for j in actual
      new_interval = ( max(i[1], j[1]) - b , min(i[end], j[end]) - b )
      if new_interval[1] <= new_interval[2]
        push!(to_add, new_interval)
      end
    end
    push!(new_previous, sort(collect(to_add), by = x -> x[1]))
  end
  new_bias = vcat([fill(b, length(x)) for (b, x) in zip(bias, new_previous)]...)
  return vcat(new_previous...), new_bias
end

for j in reverse( range(1, length(endpoints) - 1) )
  previous = endpoints[j]
  bias = biases[j]
  actual = endpoints[j + 1]
  new_previous, new_bias = pull_back(previous, bias, actual)
  endpoints[j] = new_previous
  biases[j] = new_bias
end

final_endpoints = endpoints[1]

to_eval = [final_endpoints[j][1] for j in range(2, length(final_endpoints))]
push!(to_eval, final_endpoints[1][2])
sort!(to_eval)
new_biases = compose_all.(to_eval, Ref(mappers)) - to_eval

function get_evaluations(bounds)
  intersection_intervals = Array{Any}(undef, 0)
  for interval in final_endpoints
    new_interval = (max(interval[1], bounds[1]), min(interval[end], bounds[end]))
    if new_interval[1] > new_interval[2]
      continue
    end
    push!(intersection_intervals, new_interval )
  end
  to_eval_inteval = Set([x[1] for x in intersection_intervals])
  return minimum(compose_all.(to_eval_inteval, Ref(mappers)))
end

println( Int(minimum(get_evaluations.(seeds_p2))) )




