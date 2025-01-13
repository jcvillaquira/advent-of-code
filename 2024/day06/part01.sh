#!/bin/sh

# Loading the map and initial position.
readarray -t lines < "day06/input"
y0=$(grep -n "\^" day06/input | grep -o "[0-9]\+")
y0=$((y0-1))
x0=$(echo ${lines[$y0]} | grep --byte-offset --only-matching "\^" | grep -o "[0-9]\+")
yf=${#lines[@]}
xf=${#lines[0]}

# Create a mask of boolean vectors, initialized at false
declare -A mask
mask[$y0,$x0]=true

# Create movement directions
direction=u
declare -A next=([u]=r [r]=d [d]=l [l]=u)
declare -A dx
dx[u]=0; dx[r]=1; dx[d]=0; dx[l]=-1
declare -A dy
dy[u]=-1; dy[r]=0; dy[d]=1; dy[l]=0

# Guard movement
while true
do
  let x=x0+dx[$direction]
  let y=y0+dy[$direction]
  if ! [[ 0 -le $x && 0 -le $y && $x -lt $xf && $y -lt $yf ]]
  then
    break
  elif [[ ${lines[$y]:$x:1} == "#" ]]
  then
    direction=${next[$direction]}
  else
    x0=$x; y0=$y
    mask[$y0,$x0]=true
  fi
done

echo ${#mask[@]}
echo ${#mask[@]} | xclip -selection clipboard

