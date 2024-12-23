function load_data(path)
  f = open(path)
  data = readlines(f)
  close(f)
  modules = split.(data, Ref(" -> "))
  origin = [m[1] for m in modules]
  type = [x[1] for x in origin]
  name = [x[2:end] for x in origin]
  destination = [split(m[2], ", ") for m in modules]
  rays = Dict(n => Vector{Bool}() for n in name)
  types = Dict(zip(name, type))
  destinations = Dict(zip(name, destination))
  return rays, types, destinations
end

path = "day20.csv"
rays, types, destinations = load_data(path)
states = Dict()
for (n, t) in types
  if t == '%'
    states[n] = false
  elseif t == '&'
    states[n] = [false, Dict(j => false for j in keys(rays) if j != n)]
  end
end
push!(rays["roadcaster"], 0)


# Pulses are handlend in the order they are sent.

remaining = ["roadcaster"]
actual = pop!(remaining)

for d in destinations[actual]
  states
end

while length(remaining) > 0
  actual = pop!(remaining)
  type = type[actual]
  destination = destinations[actual]
  ray = pop!(rays[actual])
  if ray # High.
  else # Low.
    if type == '%'
      new_state = !states[actual]
      for d in destination
        push!(remaining, d)
        push!(rays[d], new_state)
        if types[d] == '&'
          states[d][2][actual] = new_state
        end
      end
      states[actual] = new_state
    elseif type == '&'
      states[actual][1] = ray
      new_state = !all(values(states[actual]))
      for d in destination
        push!(remaining, d)
        push!(rays[d], new_state)
        if types[d] == '&'
          states[d][2][actual] = new_state
        end
      end
    end
  end
end

rays

type

destination

