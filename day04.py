import numpy as np

with open('day04.csv') as f:
    data = f.readlines()

data = [d.replace('\n', '') for d in data]
data = [d.split(': ')[-1].split(' | ') for d in data]

winners = [set(d[0].split()) for d in data]
bets = [set(d[1].split()) for d in data]

points = list()
for w, b in zip(winners, bets):
    points.append( len(w.intersection(b)) )

def odds(n):
    if n <= 1:
        return n
    return 2 ** ( n - 1 )

sum([odds(n) for n in points])

# Part 2.
ncards = np.ones( len(data) )
for j, p in enumerate(points):
    to_add = np.zeros( len(data) )
    to_add[j + 1 : j + 1 + p] += ncards[j]
    ncards += to_add
    

print(sum(ncards))







