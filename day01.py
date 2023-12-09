# %%
import pandas as pd
import numpy as np

df = pd.read_csv('day01.csv', header = None)
s = df[0].to_list()

dict_digits = {
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
}
digits = set(dict_digits).union(dict_digits.values())

s = ['two1nine', 'eightwothree', 'abcone2threexyz', 'xtwone3four', '4nineeightseven2', 'zoneight234', '7pqrstsixteen']

# %%
ss = list()
for x in s:
    idx = dict()
    for d in digits:
        idx[d] = (str.find(x, d), str.rfind(x, d))
    ss.append(idx)

# %%
appearences = [pd.DataFrame(l) for l in ss]
app = list()
for df in appearences:
    min_ = df.loc[0].replace(-1, np.infty)
    max_ = df.loc[1].replace(-1, -np.infty)
    app.append( (min_, max_) )

# %%
min_digit = [a[0].idxmin() for a in app]
max_digit = [a[1].idxmax() for a in app]

min_digit_ = [dict_digits.get(d, d) for d in min_digit]
max_digit_ = [dict_digits.get(d, d) for d in max_digit]

cal = [int(''.join(k)) for k in zip(min_digit_, max_digit_)]

sum(cal)

