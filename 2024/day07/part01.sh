evaluate () {
  # Check the terminal condition
  if (( $2 == 1 && $1 == $3 )); then
    return 1
  elif (( $2 == 1 )); then
    return 0
  fi
  # Get the last variable and result
  local lastpos=$(($2+2))
  local lastval=${!lastpos}
  # Call the function assuming sum
  if (( $1 < $lastval )); then
    return 0
  elif (( $1 > $lastval )); then
    # Call the function assuming sum
    newresult=$(( $1 - $lastval ))
    newlength=$(( $2 - 1 ))
    newargs=($newresult $newlength "${@:3:${#@}-3}")
    evaluate ${newargs[@]}
    if (( $? == 1 )); then
      return 1
    fi
  fi
  # Check and call the function assuming multiplication
  if (( $1 % ${!lastpos} == 0 ))
  then
    newresult=$(( $1 / $lastval ))
    newlength=$(( $2 - 1 ))
    newargs=($newresult $newlength "${@:3}")
    evaluate ${newargs[@]}
    if (( $? == 1 )); then
      return 1
    fi
  fi
  return 0
}

cumulative=0
while read -r line; do
  idx=$(echo $line | grep --only-matching --byte-offset ": " | grep -o "[0-9]\+")
  result=${line:0:$idx}
  read -a factors <<< ${line:(($idx + 1))}
  evaluate $result ${#factors[@]} ${factors[@]}
  if (( $? == 1 )); then
    cumulative=$(($cumulative + $result))
  fi
done < day07/input
echo "cumulative = $cumulative"
echo $cumulative | xclip -selection clipboard
