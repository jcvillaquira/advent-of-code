using IterTools
using ProgressBars
using Debugger
using BSON: @save, @load
using Dates

function load_data(path)
  f = open(path)
  data = readlines(f)
  close(f)
  separations = findall(length.(data) .== 0)
  separations = [0, separations..., length(data) + 1]
  terrains = Array{Array{Bool}}(undef, length(separations) - 1)
  for j in range(1, length(separations)-1)
    p0 = separations[j] + 1
    p1 = separations[j+1] - 1
    terrains[j] = permutedims(stack(collect.(data[p0:p1]))) .== '#'
  end
  return terrains
end

terrains = load_data("day13.csv")

actual_symmetries = Vector{Any}()
for terrain in terrains
  h_lines, v_lines = size(terrain) .- 1
  symmetric_v = findall(is_symmetric.(Ref(terrain), range(1, v_lines)))
  symmetric_h = findall(is_symmetric.(Ref(permutedims(terrain)), range(1, h_lines)))
  push!(actual_symmetries, (symmetric_v, symmetric_h))
end

function find_smudge(terrain, actual_symmetry)
  to_change = Iterators.product(range(1, size(terrain, 1)), range(1, size(terrain, 2)))
  to_return = Vector{CartesianIndex}()
  for coordinate in CartesianIndex.(to_change)
    terrain[coordinate] = !terrain[coordinate]
    h_lines, v_lines = size(terrain) .- 1
    symmetric_v = findall(is_symmetric.(Ref(terrain), range(1, v_lines)))
    symmetric_h = findall(is_symmetric.(Ref(permutedims(terrain)), range(1, h_lines)))
    terrain[coordinate] = !terrain[coordinate]
    if (symmetric_v, symmetric_h) == actual_symmetry
      continue
    elseif length(symmetric_v) + length(symmetric_h) > 0
      return coordinate
    end
  end
  return to_return
end

smudges = find_smudge.(terrains, actual_symmetries)

function is_symmetric(terrain, h)
  lhs = terrain[:, 1:h]
  rhs = terrain[:, h+1:end]
  width = min(size.([lhs, rhs], Ref(2))...)
  new_lhs = lhs[:, end-width+1:end]
  new_rhs = rhs[:, 1:width]
  return all(new_lhs .== reverse(new_rhs, dims = 2))
end

result = 0
for (j, terrain) in enumerate(terrains)
  smudge = smudges[j]
  terrain[smudge] = !terrain[smudge]
  h_lines, v_lines = size(terrain) .- 1
  symmetric_v = findall(is_symmetric.(Ref(terrain), range(1, v_lines)))
  symmetric_h = findall(is_symmetric.(Ref(permutedims(terrain)), range(1, h_lines)))
  terrain[smudge] = !terrain[smudge]
  new_symmetric_v = setdiff( symmetric_v, actual_symmetries[j][1] )
  new_symmetric_h = setdiff( symmetric_h, actual_symmetries[j][2] )
  result += sum(new_symmetric_v) + 100 * sum(new_symmetric_h)
end
result
