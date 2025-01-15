clear

# Load data
declare -A rules
declare -a input
while read -r line; do
  if [[ $line == *"|"* ]]; then
    IFS='|' read -a temp <<< $line
    if ! [[ -v rules[${temp[1]}] ]]; then
      rules[${temp[1]}]=""
    fi
    rules[${temp[1]}]="${rules[${temp[1]}]} ${temp[0]}"
  elif [[ $line == *","* ]]; then
    input+=($line)
  fi
done < day05/input

# Determine validity
declare -A invalid
for (( j = 0; j < ${#input[@]}; j++ )); do
  declare -A before=()
  IFS=',' read -a update <<< ${input[$j]}
  for n in ${update[@]}; do # iterate over one line of the input
    if [[ -v before[$n] ]]; then
      invalid[$j]=1
      break
    fi
    read -a prev <<< ${rules[$n]}
    for m in ${prev[@]}; do # add those that should go before n
      before[$m]=1
    done
  done
done

# Part two
for (( j = 0; j < ${#input[@]}; j++ )); do
  if ! [[ -v invalid[$j] ]]; then
    continue
  fi
  echo $j
done
