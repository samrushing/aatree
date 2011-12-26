# -*- Mode: Python -*-

from aatree import multimap
import random

t0 = multimap()
for i in range (20):
    x = random.randint (0, 100)
    y = random.choice ('abcdefghijklmnopqrstuvwxyz')
    t0.insert (x, y)

for x in t0:
    print (x.key, x.val),
print

as_list = [(x.key,x.val) for x in t0]
for i in range (5):
    k,v = random.choice (as_list)
    print 'deleting %r' % (k,)
    del t0[k]

for x in t0:
    print (x.key, x.val),
print
