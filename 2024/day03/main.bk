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
full_regex = r"do\(\)|don't\(\)|mul\((\d{1,3}),(\d{1,3})\)"

result = 0
for d in ProgressBar(data)
  local_result, multiplier = 0, 1
  aux = d
  while true
    mth = match(full_regex, aux)
    if isnothing(mth)
      break
    elseif mth.match == "do()"
      multiplier = 1
    elseif mth.match == "don't()"
      multiplier = 0
    else
      local_result += multiplier * parse(Int, mth[1]) * parse(Int, mth[2])
    end
    aux = aux[mth.offset + 1 : end]
  end
  println(local_result)
  global result += local_result
end
println(result)
