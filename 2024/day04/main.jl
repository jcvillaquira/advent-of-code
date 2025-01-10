# Imports
using DataStructures
using ProgressBars

# Load data
## Open file.
f = open("day04/input")
data = readlines(f)
close(f)

xmas = hcat(collect.(data)...)
mask = collect.( Tuple.( findall( xmas .== 'X' ) ) )

# Part 1
lbounds = [1, 1]
ubounds = collect(size(xmas))
directions = [[px, py] for px in [-1, 0, 1] for py in [-1, 0, 1] if abs(px) + abs(py) > 0]
word = ['M', 'A', 'S']

# counter = 0
# for xpos in ProgressBar(mask)
#   for d in directions
#     for j in range(1, 3)
#       new_coord = xpos + j * d
#       if !all( lbounds .<= new_coord .<= ubounds )
#         break
#       elseif xmas[new_coord...] != word[j]
#         break
#       elseif j == 3
#         global counter += 1
#       end
#     end
#   end
# end
# println(counter)

# Part 2
l1 = ['M' '.' 'S'; '.' 'A' '.'; 'M' '.' 'S']
faces = [l1, permutedims(l1), reverse(l1, dims = 2), reverse(permutedims(l1), dims = 1)]
msk = findall( faces[1] .!= '.' )
faces = [f[msk] for f in faces]

counter = 0
for j in range(0, size(xmas, 1) - 3)
  for k in range(0, size(xmas, 2) - 3)
    ci = CartesianIndex(j, k)
    ci_msk = [m + ci for m in msk]
    for f in faces
      if all( xmas[ci_msk] .== f )
        global counter += 1
        break
      end
    end
  end
end

println(counter)

