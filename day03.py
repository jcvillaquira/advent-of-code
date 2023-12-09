import numpy as np
from tqdm import tqdm
from itertools import product

with open('day03.csv') as f:
    schema = f.readlines()

schema = [list(s.replace('\n', '')) for s in schema]
array = np.array(schema)

# %%
# Part 1.

# %%
masks = list()
for j in tqdm(range(len(array))):
    mask = np.zeros(array.shape).astype(bool)
    for k, v in enumerate(array[j, :]):
        mask[j, k] = v.isdigit()
        if (not v.isdigit()) and mask.any():
            masks.append(mask)
            mask = np.zeros(array.shape).astype(bool)
    if mask.any():
        masks.append(mask)

# %%
import time as tm
t0 = tm.time()
new_masks = list()
for m in tqdm(masks):
    n = np.zeros(m.shape).astype(bool)
    for j in range(len(m)):
        for k, v in enumerate(m[j, :]):
            jj = max(j-1, 0)
            kk = max(k-1, 0)
            n[j, k] = m[jj:j+2, kk:k+2].any()
    new_masks.append(n)

print(tm.time() - t0)

# %%
invalid = {'.'}.union( [str(j) for j in range(10)] )
numbers = list()
for m, n in tqdm(zip(masks, new_masks)):
    if not set(array[n]).issubset(invalid):
        numbers.append(int(''.join( array[m] )))

sum(numbers)

# %%
# Part 2.

# %%
pseudogears = list()
for j, k in product(range(array.shape[0]), range(array.shape[1])):
    if array[j, k] == '*':
        pseudogears.append( (j, k) )

# %%
gears = dict()
for g in tqdm(pseudogears):
    c = 0
    r = list()
    for m, n in zip(masks, new_masks):
        dc = n[g[0], g[1]]
        c += int(dc)
        if dc:
            r.append(int(''.join( array[m] )))
    if c == 2:
        gears[g] = r

ratios = [g[0] * g[1] for g in gears.values()]
sum(ratios)



