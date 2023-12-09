## Open file.
f = open("day08.csv")
data = readlines(f)
close(f)

instructions = collect(data[1])
steps  = Dict('L' => 1, 'R' => 2)

directions = data[3:end]
origin = [split(d, " = ")[1] for d in directions]
destination = [(split(d, " = ")[2][2:4], split(d, " = ")[2][7:9]) for d in directions]

guide = Dict(zip(origin, destination))

starting = origin[[x[end] for x in origin] .== 'A']
nsteps = Array{Int}(undef, 0)
for s in starting
  n = 0
    current = s
  for i in Iterators.cycle(instructions)
    direction = steps[i]
    current = guide[current][direction]
    n += 1
    if current[end] == 'Z'
      break
    end
  end
  push!(nsteps, n)
end

lcm(nsteps)


