## Open file.
f = open("day11.csv")
data = readlines(f)
close(f)

expansion = 1

universe = permutedims(stack(collect.(data)))
new_rows = Array{Any}(undef, 0)
nrows = size(universe, 1)
for n in range(1, nrows)
  row = universe[n, :]
  push!(new_rows, row)
  if all(row .== '.')
    for j in range(1, expansion)
      push!(new_rows, row)
    end
  end
end

universe = permutedims(stack(new_rows))
new_cols = Array{Any}(undef, 0)
ncols = size(universe, 2)
for n in range(1, ncols)
  col = universe[:, n]
  push!(new_cols, col)
  if all(col .== '.')
    for j in range(1, expansion)
      push!(new_cols, col)
    end
  end
end

universe = stack(new_cols)
galaxies_mask = universe .== '#'
galaxies = findall(galaxies_mask)

galaxies_array = (x -> [x[1], x[2]]).(galaxies)
# distances = Array{Any}(undef, 0)
distances1 = Array{Any}(undef, 0)
for (j, g) in enumerate(galaxies_array)
  if j == length(galaxies_array)
    continue
  end
  for gg in galaxies_array[j+1:end]
    push!(distances1, sum(abs.(g - gg)))
  end
end


delta = distances1 - distances

sum(distances + (1000000 - 1) * delta)


