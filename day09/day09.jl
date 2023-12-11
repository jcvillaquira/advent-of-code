## Open file.
f = open("day09.csv")
data = readlines(f)
close(f)
data = [parse.(Ref(Int), split(x)) for x in data]

function get_extrapolation(data1)
  array = [data1]
  while true
    new_array = diff(array[end])
    push!(array, new_array)
    if all( new_array .== 0 )
      break
    end
  end
  array2 = [data1]
  for new_array in array[2:end]
    to_pad = length(data1) - length(new_array)
    new_array2 = vcat(new_array, zeros(to_pad))
    push!(array2, new_array2)
  end
  result = permutedims(stack(array2))
  result2 = hcat(zeros(size(result, 1)), result)
  for j in reverse(range(1, size(result2, 1) - 1))
    result2[j,1] = result2[j,2] - result2[j+1,1]
  end
  return result2[1, 1]
end

sum(get_extrapolation.(data))

