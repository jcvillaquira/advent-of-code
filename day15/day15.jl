function load_data(path)
  f = open(path)
  data = readlines(f)[1]
  close(f)
  return collect.(split(data, ','))
end

function apply_step(n, c)
  n += c
  n = 17 * n
  n = mod(n, 256)
  return n
end

path = "day15.csv"
data = load_data(path)

mapper = Dict(true => '-', false => '=')
operation = [('-' in x) for x in data]
pos = [findfirst(x .== get(mapper, y, nothing)) for (x, y) in zip(data, operation)]
number = [v ? 0 : parse(Int, join(x[p+1:end])) for (x, v, p) in zip(data, operation, pos)]
labels = [join(x[1:p-1]) for (x, p) in zip(data, pos)]
steps = [Int.(collect(x)) for x in labels]

box_mapper = similar(steps, Int)
for (j, s) in enumerate(steps)
  rs = 0
  for c in s
    rs = apply_step(rs, c)
  end
  box_mapper[j] = rs
end

boxes = Dict(x => [Vector{Any}(), Vector{Int}()] for x in range(0, 255))
for (b, l, o, n) in zip(box_mapper, labels, operation, number)
  box = boxes[b]
  p = findfirst(box[1] .== l)
  p_exists = !isnothing(p)
  if o # If operation == '-'
    if p_exists
      deleteat!(box[1], p)
      deleteat!(box[2], p)
    end
  else # If operation == '='
    if p_exists
      box[2][p] = n
    else
      push!(box[1], l)
      push!(box[2], n)
    end
  end
end
boxes = Dict(k => box for (k, box) in boxes if length(box[1]) > 0)

result = 0
for (k, box) in boxes
  for (j, b) in enumerate(box[2])
    result += (1 + k) * j * b
  end
end
result

boxes


