with open('iso_list/valid_list.txt') as i:
    names = i.readlines()
with open('iso_list/valid.prediction') as i:
    p = i.readlines()
out = open('iso_list/valid_prediction.txt', 'w')
assert len(names) == len(p)
for i, n in enumerate(names):
    n = n[:-1]
    result = n + ' ' + p[i]
    out.write(result)
