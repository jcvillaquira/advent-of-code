# Imports
using DataStructures

# Load data
## Open file.
f = open("day03/input")
data = readlines(f)
close(f)

dore = r"do\(\)"
dont = r"don't\(\)"
re = r"mul\((\d{1,3}),(\d{1,3})\)"
prs = x -> parse(Int, x)

function matchdont(txt)
  mth = match(dont, txt)
  idx = length(txt)
  if !isnothing(mth)
    idx = mth.offset
  end
  return txt[1:idx-1], txt[idx+7:end]
end

result = 0
for d in data[4:4]
  txt = d
  while true
    txt0, txt1 = matchdont(txt)
    for m in eachmatch(re, txt0)
      global result += prs(m[1]) * prs(m[2])
    end
    mth = match(dore, txt1)
    if isnothing(mth)
      break
    end
    txt = txt1[mth.offset+5:end]
  end
end

