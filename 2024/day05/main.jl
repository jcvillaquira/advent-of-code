# Imports
using DataStructures
using ProgressBars

# Load data
## Open file.
f = open("day05/input")
data = readlines(f)
close(f)

# Find where the sections change.
pos = findfirst( data .== "" )
p1 = data[1:pos-1]
d1 = DefaultDict{Int, Set{Int}}(Set())
for x in p1
  k1 = parse(Int, x[1:2])
  k2 = parse(Int, x[4:end])
  push!(d1[k1], k2)
end

p2 = data[pos+1:end]
d2 = [parse.(Ref(Int), split(x, ",")) for x in p2]
result = 0
for manual in d2
  appeared = Set()
  to_add = true
  for x in manual
    to_add &= isdisjoint(appeared, d1[x])
    if !to_add
      break
    end
    push!(appeared, x)
  end
  if to_add
    idx = ( length(manual) + 1 ) / 2
    global result += manual[Int(idx)]
  end
end
println(result)
