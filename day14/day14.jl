using ProgressBars

function load_data(path)
  f = open(path)
  data = readlines(f)
  close(f)
  platform_char = permutedims(stack(collect.(data)))
  platform = similar(platform_char, Int)
  platform[platform_char .== '.'] .= 0
  platform[platform_char .== 'O'] .= 1
  platform[platform_char .== '#'] .= -1
  return platform
end

function tilt(col, direction)
  squares = [0, findall(col .== -1)..., length(col) + 1]
  regions = [col[k+1:l-1] for (k, l) in zip(squares[1:end-1], squares[2:end])]
  new_regions = similar(regions)
  for (k, region) in enumerate(regions)
    n_ball = sum(region)
    if direction
      new_region = [ones(Int, n_ball)..., zeros(Int, length(region) - n_ball)...] 
    else
      new_region = [zeros(Int, length(region) - n_ball)..., ones(Int, n_ball)...] 
    end
    new_regions[k] = new_region
  end
  new_regions = [[nr..., -1] for nr in new_regions]
  return vcat(new_regions...)[1:end-1]
end

function one_clycle(platform)
  platform = stack(tilt.(eachslice(platform, dims = 2), Ref(true)))
  platform = permutedims(stack(tilt.(eachslice(platform, dims = 1), Ref(true))))
  platform = stack(tilt.(eachslice(platform, dims = 2), Ref(false)))
  platform = permutedims(stack(tilt.(eachslice(platform, dims = 1), Ref(false))))
  return platform
end

path = "day14.csv"
platform = load_data(path)
period0 = nothing
period1 = nothing
history = Vector{Any}()
for j in ProgressBar(range(1, 1_000_000_000))
  platform = one_clycle(platform)
  if platform in history
    period0 = findfirst([all(p .== platform) for p in history])
    period1 = j
    push!(history, platform)
    break
  end
  push!(history, platform)
end

total_cycles = period0 + mod(1_000_000_000 - period0, period1 - period0)
path = "day14.csv"
platform = load_data(path)
for j in ProgressBar(range(1, total_cycles))
  platform = one_clycle(platform)
end

tilted_pad = eachslice(platform, dims = 2)
# tilted_pad = tilt.(tilted_pad, true)
weight = reverse(collect(range(1, size(platform, 1))))

function compute_column_effect(col, weight)
  balls = Int.( col .== 1 )
  return sum(balls .* weight)
end

sum(compute_column_effect.(tilted_pad, Ref(weight)))

