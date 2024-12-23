# Imports
using DataStructures

# Load data
## Open file.
f = open("day01/input")
data = readlines(f)
close(f)

## Parser.
prs = x -> parse(Int, x)

## Match numbers.
re = r"^(\d+)\s+(\d+)$"
matches = [match(re, f) for f in data]
l1 = sort(prs.([m[1] for m in matches]))
l2 = sort(prs.([m[2] for m in matches]))

# Part 1
# print(sum(abs.(l1 .- l2)))

# Part 2
appearances = DefaultDict(0)
for k in l1
  appearances[k] += 1
end

counter = DefaultDict(0)
for k in l2
  counter[k] += 1
end

# print(sum([k * a * counter[k] for (k, a) in appearances]))
