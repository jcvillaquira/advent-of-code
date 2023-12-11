## Open file.
f = open("day07.csv")
data = readlines(f)
close(f)

games = [split(x)[1] for x in data]
bid = [parse(Int, split(x)[2]) for x in data]

function get_type(hand)
  hand = collect(hand)
  l = length(unique(hand)) 
  if l >= 4 # One pair, high card.
    return - l + 6
  elseif l == 1 # Five of a kind.
    return 7
  elseif l == 2
    t = hand[1]
    if (sum(hand .== t) == 1) || (sum(hand .== t) == 4)
      return 6
    else
      return 5
    end
  else
    t = hand[1]
    s = hand[2]
    r = hand[3]
    if (sum(hand .== t) == 3) || (sum(hand .== s) == 3) || (sum(hand .== r) == 3)
      return 4
    else
      return 3
    end
  end
end

symbols = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J']

function get_modified_type(hand)
  hand = collect(hand)
  t = get_type(hand)
  if ~('J' in hand)
    return t
  end
  other_cards = Set([x for x in hand if x != 'J'])
  for c in other_cards
    hand_mod = replace(hand, 'J' => c)
    t = max(t, get_type(hand_mod))
  end
  return t
end

points = Dict(zip( reverse(symbols), range(1, length(symbols)) ))
function compare_hands(h1, h2)
  t1 = get_modified_type(h1)
  t2 = get_modified_type(h2)
  if t1 > t2
    return true
  elseif t2 > t1
    return false
  end
  p1 = [points[x] for x in collect(h1)]
  p2 = [points[x] for x in collect(h2)]
  mask = (p1 .!= p2)
  q1 = p1[mask][1]
  q2 = p2[mask][1]
  return q1 > q2
end

ordered = [games[1]]
for h1 in games[2:end]
  for (k, h2) in enumerate(ordered)
    if compare_hands(h1, h2)
      insert!(ordered, k + 1, h1)
      break
    end
  end
end

order = Dict()
for h1 in games
  c = 1
  for h2 in games
    if h1 != h2
      c += compare_hands(h1, h2)
    end
  end
  order[h1] = c
end

s = 0
bids = Dict(zip(games, bid))
for (g, r) in order
  s += bids[g] * r
end
s

