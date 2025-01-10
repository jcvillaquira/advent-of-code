# Imports
using DataStructures
using ProgressBars

# Load data
## Open file.
f = open("day03/input")
data = readlines(f)
close(f)

dore = r"do\(\)"
dont = r"don't\(\)"
re = r"mul\((\d{1,3}),(\d{1,3})\)"
prs = x -> parse(Int, x)

result = 0
for d in ProgressBar(data)
  aux = d
  while true
    mth = match(re, aux)
    if isnothing(mth)
      break
    end
    global result += parse(Int, mth[1]) * parse(Int, mth[2])
    aux = aux[mth.offset + 1 : end]
  end
end
println(result)
