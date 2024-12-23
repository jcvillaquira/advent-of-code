using IterTools
using ProgressBars
using Debugger
using BSON: @save, @load
using Dates

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
  if isnothing(starting) # If there is only zeros.
    return nothing
  end
  if n > length(list) - starting + 1 # If there is no space for block.
    return nothing
  end
  sub_block = list[starting:starting+n-1]
  if (sub_block[end] != 1) && all(sub_block[1:end-1] .>= 1)
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
    if !isnothing(ds)
      starting += ds
      if (starting == 1) || (list[starting-1] != 1)
        push!(to_return, starting)
      end
    else
      ds = findfirst(list[starting+1:end] .!= 1)
      if isnothing(ds)
        break
      end
      starting += ds
    end
  end
  return to_return
end

function count_ways(rr, dd, c_time)
  """
  Count possible ways for dd to fit in rr.
  """
  # if Dates.value(Dates.now() - c_time) > 30_000
  #   return nothing
  # end
  ways = 0
  possible_block_1 = find_possible_positions(rr, dd[1] + 1)
  if length(dd) == 1
    last_one = findlast(rr .== 1)
    if isnothing(last_one)
      return length( possible_block_1 )
    end
    return count( possible_block_1 .> last_one - dd[1] )
  end
  new_dd = dd[2:end]
  n_blocks = length(new_dd)
  total_spaces = sum(new_dd) + n_blocks
  for p in possible_block_1
    new_rr = rr[p+dd[1]+1:end]
    if (length(new_rr) < total_spaces) || (count(new_rr .== 0) > n_blocks)
      break
    end
    to_add = count_ways(new_rr, new_dd, c_time)
    # if isnothing(to_add)
    #   return nothing
    # end
    ways += to_add
  end
  return ways
end

j = 1
rr = rows[j]
dd = dist[j]
@time count_ways(rr, dd, Dates.now())


path = "day12.csv"
rows, dist, _, _ = load_data(path, expand = 5);

@load "total_ways.bson" total_ways

remaining = [x for x in range(1, 1_000) if !(x in keys(total_ways))]
iter = ProgressBar(remaining)
Threads.@threads for j in iter
  rr = rows[j]
  dd = dist[j]
  rri = [reverse(rr[1:end-1])..., 0]
  ddi = reverse(dd)
  to_add = count_ways(rri, ddi, Dates.now())
  if !isnothing(to_add)
    total_ways[j] = to_add
  end
end

@save "total_ways.bson" total_ways

