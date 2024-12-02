## Open file.
f = open("day10.csv")
data = readlines(f)
close(f)

array = permutedims( stack( collect.(data) ) )

symbols = ['-', '7', '|', 'J', 'L', 'F']
directions = [ [(-1, 0), (1, 0)], [(-1, 0), (0, -1)], [(0, 1), (0, -1)], [(-1, 0), (0, 1)], [(1, 0), (0, 1)], [(0, -1), (1, 0)] ]
guide = Dict(zip(symbols, directions))

yl, xl = size(array)
loop = [argmax(array .== 'S')]
feasible = nothing
S = loop[end]
for dx in [-1, 0, 1]
  for dy in [-1, 0, 1]
    if (dx == dy == 0) || ((dx != 0) && (dy != 0)) # If unfeasible.
      continue
    end
    y = S[1] - dy
    x = S[2] + dx
    if (x < 1) || (y < 1) || (x > xl) || (y > yl) # Outside the grid.
      continue
    end
    yx = CartesianIndex(y, x)
    Ss = array[yx]
    if (-dx, -dy) in get(guide, Ss, []) # If makes sense, add to feasible.
      feasible = yx
      break
    end
  end
end
push!(loop, feasible)

while true
  Sp = loop[end-1]
  S = loop[end]
  s = array[S]
  dx, dy = ( S[2] - Sp[2] , -(S[1] - Sp[1]) )
  j = 1
  if (-dx, -dy) == guide[s][1]
    j = 2
  end
  to_add = guide[s][j]
  to_push = CartesianIndex( S[1] - to_add[2] , S[2] + to_add[1] )
  push!(loop, to_push)
  if array[to_push] == 'S'
    break
  end
end

x = collect(range(0, length(loop) - 1))
loop_array = [[s[2], -s[1]] for s in loop]
path = loop_array[2:end]
dloop = diff(loop_array)
area = abs(sum([x[2]*dx[1] - x[1]*dx[2] for (x, dx) in zip(path, dloop)]) / 2)
angles = (1 / 2) * length(path) - 2

area - angles - 1



