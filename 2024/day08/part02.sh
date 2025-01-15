clear

# Read the input
readarray -t lines < day08/input
bound0=${#lines[@]}
bound1=${#lines[0]}

# Organize the input
declare -A antennas
for (( j = 0; j < ${#lines[@]}; j++ ))
do
  line=${lines[$j]}
  for (( k = 0; k < ${#line}; k++ ))
  do
    val=${line:$k:1}
    if ! [[ $val == "." ]]
    then
      if ! [[ -v antennas[$val] ]]
      then
        antennas[$val]=""
      fi
      antennas[$val]="${antennas[$val]} $j,$k"
    fi
  done
done

# Check if the two parameters are within bounds
within_bounds () {
  if [[ $1 -lt 0 || $1 -ge $bound0 || $2 -lt 0 || $2 -ge $bound1 ]]
  then
    return 0
  fi
  return 1
}

# Iterate over the antennas
declare -A result
for antenna in ${!antennas[@]}
do
  read -a pos <<< ${antennas[$antenna]}
  for (( a0 = 0; a0 < ${#pos[@]}; a0++ ))
  do
    for (( a1 = (( $a0 + 1 )); a1 < ${#pos[@]}; a1++ ))
    do
      IFS=',' read -a coord0 <<< ${pos[$a0]}
      IFS=',' read -a coord1 <<< ${pos[$a1]}
      d0=$(( ${coord1[0]} - ${coord0[0]} ))
      d1=$(( ${coord1[1]} - ${coord0[1]} ))
      # Go back from a0
      for (( k = 0; ; k++ ))
      do
        newcoord0=$(( ${coord0[0]} - $k * $d0 ))
        newcoord1=$(( ${coord0[1]} - $k * $d1 ))
        within_bounds $newcoord0 $newcoord1
        if [[ $? -eq 1 ]]
        then
          result[$newcoord0,$newcoord1]=1
        else
          break
        fi
      done
      # Go forward from a1
      for (( k = 0; ; k++ ))
      do
        newcoord0=$(( ${coord1[0]} + $k * $d0 ))
        newcoord1=$(( ${coord1[1]} + $k * $d1 ))
        within_bounds $newcoord0 $newcoord1
        if [[ $? -eq 1 ]]
        then
          result[$newcoord0,$newcoord1]=1
        else
          break
        fi
      done
    done
  done
done

echo "result = ${#result[@]}"
echo ${#result[@]} | xclip -selection clipboard
