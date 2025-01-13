#!/bin/sh

# Loading the map and initial position.
readarray -t lines < "day06/input"
y00=$(grep -n "\^" day06/input | grep -o "[0-9]\+")
y00=$((y00-1))
x00=$(echo ${lines[$y00]} | grep --byte-offset --only-matching "\^" | grep -o "[0-9]\+")
yf=${#lines[@]}
xf=${#lines[0]}

# Preliminaires
declare -A next=([u]=r [r]=d [d]=l [l]=u)
declare -A dx
dx[u]=0; dx[r]=1; dx[d]=0; dx[l]=-1
declare -A dy
dy[u]=-1; dy[r]=0; dy[d]=1; dy[l]=0

# Create a function to determine if loop closes or not.
loop () {
  bk=${lines[$1]}
  nline=$(echo ${bk} | sed s/./#/$(($2+1)))
  lines[$1]=$nline

  direction=u
  x0=$x00; y0=$y00

  declare -A visited=([$y0,$x0,$direction] = 1)
  while true
  do
    let x=x0+dx[$direction]
    let y=y0+dy[$direction]
    # echo "$y $x $direction ${visited[$y,$x,$direction]} -"
    if ! [[ 0 -le $x && 0 -le $y && $x -lt $xf && $y -lt $yf ]]
    then
      echo 0
      break
    elif [[ ${visited[$y,$x,$direction]} == 1 ]]
    then
      echo 1
      break
    elif [[ ${lines[$y]:$x:1} == "#" ]]
    then
      direction=${next[$direction]}
    else
      x0=$x; y0=$y
      visited[$y0,$x0,$direction]=1
    fi
  done

  lines[$1]=$bk
}

# Iterate over all possible positions for obstacles.
result=0
for ((j = 0; j < yf; j++ )); do
for ((k = 0; k < xf; k++ )); do
  if [[ ${lines[$j]:$k:1} == "." ]]
  then
    ((result += $(loop $j $k)))
  fi
  echo "$j / $yf - $k / $xf - $result"
done
done

echo "result = $result"
echo $result | xclip -selection clipboard
