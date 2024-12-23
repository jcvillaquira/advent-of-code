# Imports
using DataStructures

# Load data
## Open file.
f = open("day02/input")
data = readlines(f)
close(f)

## Parser.
prs = x -> parse(Int, x)
numbers = [prs.(split(s)) for s in data]

# Part 1.
safe = 0
for n in numbers
  localunsafe = 0
  nn = n
  increasing = nn[2] - nn[1]
  for j in range(1, length(nn) - 1)
    cond = (increasing * ( nn[j+1] - nn[j] ) > 0) && (1 <= abs( nn[j+1] - nn[j] ) <= 3)
    if !cond
      localunsafe = 1
      break
    end
  end
  if localunsafe == 0
    global safe += 1
    continue
  end
  for k in range(1, length(n))
    nn = [n[1:k-1]..., n[k+1:end]...]
    localunsafe = 0
    increasing = nn[2] - nn[1]
    for j in range(1, length(nn) - 1)
      cond = (increasing * ( nn[j+1] - nn[j] ) > 0) && (1 <= abs( nn[j+1] - nn[j] ) <= 3)
      if !cond
        localunsafe = 1
        break
      end
    end
    if localunsafe == 0
      global safe += 1
      break
    end
  end
end
print(safe)
