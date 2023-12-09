## Open file.
f = open("day06.csv")
data = readlines(f)
close(f)

time = [parse(Int, t) for t in split( data[1] )[2:end]]
distance = [parse(Int, d) for d in split( data[2] )[2:end]]

function quadratic(t, d)
  delta = sqrt(t * t - 4 * d)
  r1 = ( t - delta) / 2
  r2 = ( t + delta ) / 2
  return (Int(ceil(r1)) , Int(floor(r2)))
end

function modify_record( bounds, t, d )
  b1 = bounds[1] * ( t - bounds[1] ) <= d
  b2 = bounds[2] * ( t - bounds[2] ) <= d
  return (bounds[1] + Int(b1), bounds[2] - Int(b2))
end

output = Array{Int}(undef, 0)
for (j, t) in enumerate(time)
  bounds = quadratic(t, distance[j] )
  record = modify_record(bounds, t, distance[j])
  push!( output, record[2] + 1 - record[1] )
end

prod(output)







