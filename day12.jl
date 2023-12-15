using IterTools
using ProgressBars
using Debugger
using BSON: @save, @load

function load_data(path; expand = 1)
  ## Open file.
  f = open(path)
  data = readlines(f)
  close(f)
  report = split.(data)
  ## Clear data.
  rows = [join([x[1] for _ in range(1, expand)], '?') for x in report]
  dist = [join([x[2] for _ in range(1, expand)], ',') for x in report]
  clean_row(row) = join([x for x in split(row, ".") if length(x) > 0], ".")
  clean_dist(d) = parse.(Ref(Int), split(d, ","))
  rows = collect.(clean_row.(rows))
  new_rows = Vector{Vector{Int}}()
  for row in rows
    new_row = similar(row, Int)
    new_row[row .== '?'] .= 2
    new_row[row .== '.'] .= 0
    new_row[row .== '#'] .= 1
    push!(new_rows, [new_row..., 0])
  end
  ## Clear data.
  rows = new_rows
  dist = clean_dist.(dist)
  masks = [findall(x .== 2) for x in rows] 
  samples = [vcat([Int.([ones(x)..., 0]) for x in dd]...)[1:end-1] for dd in dist]
  return rows, dist, masks, samples
end

function get_sample(rr)
  mask = Bool.(max.(rr, [0, rr[1:end-1]...]))
  if rr[end] == 1
    return rr[mask]
  end
  return rr[mask][1:end-1]
end

function put_block(list, n)
  """
  Put block ([1, 1, 0]) of length n (3) in the first position possible.
  Return the first possible position, nothing otherwise.
  """
  starting = findfirst(list .!= 0) # When there are no spaces.
  if starting == nothing # If there is only zeros.
    return nothing
  end
  if n > length(list) - starting + 1 # If there is no space for block.
    return nothing
  end
  sub_block = list[starting:starting+n-1]
  if all(sub_block[1:end-1] .>= 1) && (sub_block[end] != 1)
    return starting
  end
  return nothing
end

function find_possible_positions(list, n)
  """
  Find starting points of a list for a block of size n (n-1 ones).
  """
  starting = 0
  to_return = Vector{Int}()
  while true
    if starting >= length(list)
      break
    end
    if (starting > 0) && any(list[1:starting] .== 1)
      break
    end
    ds = put_block(list[starting+1:end], n)
    if (ds != nothing)
      starting += ds
      if (starting == 1) || (list[starting-1] != 1)
        push!(to_return, starting)
      end
    else
      ds = findfirst(list[starting+1:end] .!= 1)
      if ds == nothing
        break
      end
      starting += ds
    end
  end
  return to_return
end

function count_ways(rr, dd)
  """
  Count possible ways for dd to fit in rr.
  """
  possible_block_1 = find_possible_positions(rr, dd[1] + 1)
  total_ways = 0
  if length(dd) == 1
    for p in reverse(possible_block_1)
      if any(rr[p+dd[1]:end] .== 1)
        break
      end
      total_ways += 1
    end
    return total_ways
  end
  for p in possible_block_1
    new_dd = dd[2:end]
    new_rr = rr[p+dd[1]+1:end]
    total_ways += count_ways(new_rr, new_dd)
  end
  return total_ways
end

path = "day12.csv"
rows, dist, _, _ = load_data(path, expand = 5)

# total_ways = Dict{Int, Int}()
@load "total_ways.bson" total_ways

iterator = collect( enumerate(zip(rows, dist)) )
iterator = sort(iterator, by = x -> length(x[2][1]))
iter = ProgressBar(iterator[101:200])
Threads.@threads for data in iter
  j = data[1]
  if get(total_ways, j, -1) != -1
    set_description(iter, "O - " * string(j))
    continue
  end
  rr, dd = data[2]
  total_ways[j] = count_ways(rr, dd)
  set_description(iter, "F - " * string(j))
end

@save "total_ways.bson" total_ways

