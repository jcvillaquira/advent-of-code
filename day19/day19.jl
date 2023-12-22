using ProgressBars
using DataStructures

function load_data(path)
  f = open(path)
  data = readlines(f)
  idx = findfirst( length.(data) .== 0 )
  instructions = collect.(data[1:idx-1])
  idx_instructions = [findfirst(x .== '{') for x in instructions]
  name = [join(x[1:j-1]) for (x, j) in zip(instructions, idx_instructions)]
  operations_string = [join(x[j+1:end-1]) for (x, j) in zip(instructions, idx_instructions)]
  materials_string = data[idx+1:end]
  materials = similar(materials_string, Dict{Char, Int})
  for (j, m) in enumerate(materials_string)
    materials[j] = Dict(only(k[1]) => parse(Int, k[2]) for k in split.(split(m[2:end-1], ','), Ref('=')))
  end
  operations = similar(operations_string, Vector{Tuple})
  default = similar(operations, String)
  for (j, o) in enumerate(operations_string)
    inst = split(o, ',')
    actions = [split(x, ':') for x in inst[1:end-1]]
    expr = [Meta.parse(x[1]) for x in actions]
    result = [x[2] for x in actions]
    default[j] = inst[end]
    operations[j] = collect(zip(expr, result))
  end
  final_operations = Dict{String, Any}(zip(name, operations))
  final_default = Dict(zip(name, default))
  return final_operations, final_default, materials
end
operations, default, materials = load_data("day19.csv");

# Inefficient solution for part 1.
result = zeros(Bool, size(materials))
for (j, material) in ProgressBar(enumerate(materials))
  global x, a, s, m = [get(material, c, -1) for c in ['x', 'a', 's', 'm']]
  next = "in"
  while ((next != "A") && (next != "R"))
    rule = operations[next]
    next = default[next]
    for (r, n) in rule
      if eval(r)
        next = n
        break
      end
    end
  end
  result[j] = next == "A"
end
sum((x -> sum(values(x))).(materials[result]))

# Part 2.
function load_data(path)
  f = open(path)
  data = readlines(f)
  idx = findfirst( length.(data) .== 0 )
  instructions = collect.(data[1:idx-1])
  idx_instructions = [findfirst(x .== '{') for x in instructions]
  name = [join(x[1:j-1]) for (x, j) in zip(instructions, idx_instructions)]
  operations_string = [join(x[j+1:end-1]) for (x, j) in zip(instructions, idx_instructions)]
  materials_string = data[idx+1:end]
  materials = similar(materials_string, Dict{Char, Int})
  for (j, m) in enumerate(materials_string)
    materials[j] = Dict(only(k[1]) => parse(Int, k[2]) for k in split.(split(m[2:end-1], ','), Ref('=')))
  end
  operations = similar(operations_string, Vector{Tuple})
  default = similar(operations, String)
  for (j, o) in enumerate(operations_string)
    inst = split(o, ',')
    actions = [split(x, ':') for x in inst[1:end-1]]
    aux = [collect(x[1]) for x in actions]
    zone = [x[1] for x in aux]
    hyperplane = [x[2] for x in aux]
    constant = [parse(Int, join(x[3:end])) for x in aux]
    result = [x[2] for x in actions]
    expr = collect(zip(zone, hyperplane, constant, result))
    default[j] = inst[end]
    operations[j] = expr
  end
  final_operations = Dict{String, Any}(zip(name, operations))
  final_default = Dict(zip(name, default))
  return final_operations, final_default, materials
end
operations, default, materials = load_data("day19.csv");

cube = Cube('x' => [1, 4_000],
            'm' => [1, 4_000],
            'a' => [1, 4_000],
            's' => [1, 4_000])
function count_ways(cube::Dict{Char, Array{Int}}, rule, depth)
  if rule == "A"
    println(depth)
    return prod( (x -> x[2] - x[1] + 1 ).(values(cube)) )
  elseif rule == "R"
    return 0
  end
  df = true
  total_ways = 0
  for op in operations[rule]
    old_int = cube[op[1]]
    if op[2] == '<'
      new_int = op[3] > old_int[1] ? [old_int[1], min(old_int[2], op[3] - 1)] : []
      int = length(new_int) > 0 ? [new_int[2] + 1, old_int[2]] : old_int
    elseif op[2] == '>'
      new_int = op[3] < old_int[2] ? [max(old_int[1], op[3] + 1), old_int[2]] : []
      int = length(new_int) > 0 ? [old_int[1], new_int[1] - 1] : old_int
    end
    if length(new_int) > 0
      new_cube = copy(cube)
      new_cube[op[1]] = new_int
      total_ways += count_ways(new_cube, op[4], depth + 1)
    end
    if int[1] > int[2]
      df = false
      break
    end
    cube[op[1]] = int
  end
  if df
    total_ways += count_ways(cube, default[rule], depth + 1)
  end
end
result = count_ways(cube, "in", 1)

