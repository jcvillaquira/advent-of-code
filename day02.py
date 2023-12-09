# %%
import numpy as np

bounds = dict(red = 12, green = 13, blue = 14)

with open('day02.csv') as f:
    games = f.readlines()

# %%
def get_game_dict(g):
    game = g.replace('\n', '')
    game_set = [x.strip() for x in game.split(':')[-1].split(';')]
    game_list = [x.split(', ') for x in game_set]
    game_dict = [{ k.split()[-1] : int(k.split()[0]) for k in x} for x in game_list]
    return game_dict

# %%
game_dicts = [get_game_dict(g) for g in games]
games_viability = [all([all([n <= bounds.get(c) for c, n in x.items()]) for x in g]) for g in game_dicts]

it = zip(games_viability, range(1, len(games_viability) + 1))
c = 0
for g, j in it:
    if g:
        c += j
print(c)

# %%
def get_power(game):
    r, g, b = 0, 0, 0
    for match in game:
        r = max(r, match.get('red', 0))
        g = max(g, match.get('green', 0))
        b = max(b, match.get('blue', 0))
    return r * g * b

sum(get_power(game) for game in game_dicts)

# %%


match = game[0]

match













        c
