clear

# Count the solutions assuming there are not dots
counter () {
  str=$1
  arrangement=(${@:2})
  # I have no idea hot to proceed
}

reps=1
cumulative=0
while read -r line
do
  # Remove points at the beginning and blocks of consecutive points
  read -a characters <<< $line
  spring=${characters[0]}
  rule=${characters[1]}
  springs="$spring"
  rules="$rule"
  for (( k = 0; k < (( $reps - 1 )); k++ ))
  do
    springs="$springs?$spring"
    rules="$rules,$rule"
  done
  springs=$(echo $springs | sed 's/\?/0/g' | sed 's/#/1/g' )
  IFS=',' read -r -a rules <<< "$rules"
  IFS='.' read -r -a springs <<< $springs
  echo ${springs[@]}
  # Processing
  counter $springs ${rules[@]}
done < day12/day12.csv
# echo $cumulative
