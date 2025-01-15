clear

# Load data and initialize
data=$(<day09/input)
declare -a representation=()
declare -a empty=()
counter=0
while read -r r e; do
  representation[$counter]=$r
  empty[$counter]=$e
  (( counter++ ))
done <<< $(echo $data | sed 's/\([0-9]\)\([0-9]\)/\1 \2|/g' | tr '|' '\n' )
empty[$((${#empty[@]}-1))]=0

# Fill array with ID an dots
declare -a config=()
counter=0
for (( j = 0; j < ${#representation[@]}; j++ )); do
  for (( k = 0; k < ${representation[$j]}; k++)); do
    config[$counter]=$j
    (( counter++ ))
  done
  (( counter+=${empty[$j]} ))
done
keys=(${!config[@]})

# Processing
tofill=0
lastmoved=0
for (( k = ${#keys[@]} - 1; k >=0; k-- )); do
  key=${keys[$k]}
  while [[ -v config[$tofill] ]]; do
    (( tofill++ ))
  done
  if [[ $tofill -gt $key ]]; then
    break
  fi
  config[$tofill]=${config[$key]}
  lastmoved=$key
done

# Compute result
result=0
for k in ${!config[@]}; do
  if [[ $k -ge $lastmoved ]]; then
    break
  fi
  (( result += $k * ${config[$k]} ))
done
echo "result = $result"
echo $result | xclip -selection clipboard

