# -*- Mode: Python -*-

# test persistent version of the aa-tree multimap.

import unittest
from aatree import PersistentMap
import random

class TestPersistentMap (unittest.TestCase):

    def test_persistence (self):
        t0 = PersistentMap()
        random.seed (3141)
        for i in range (100):
            x = random.randint (0, 100)
            y = random.choice ('abcdefghijklmnopqrstuvwxyz')
            t0[x] = y

        t_orig = t0.copy()
        l_orig = [x.key for x in t_orig]

        as_list = [x.key for x in t0]
        for i in range (20):
            k = random.choice (as_list)
            t1 = t0.copy()
            del t0[k]
            as_list.remove (k)
            self.assertEqual ([x.key for x in t0], as_list)
            # make sure the key is still in the previous version
            self.assertTrue (k in t1)
            t1.verify()

        # verify that our original tree is unmangled.
        self.assertEqual ([x.key for x in t_orig], l_orig)

    def test_to_empty (self):
        t0 = PersistentMap()
        random.seed (3141)
        l = []
        for i in range (1000):
            k = random.randint (0, 1000000)
            t0[k] = None
            l.append (k)
        t0.verify()
        random.shuffle (l)
        size = len(t0)
        self.assertEqual (size, 1000)
        for k in l:
            del t0[k]
            size -= 1
            self.assertEqual (len(t0), size)

    def test_levels (self):
        t0 = PersistentMap()
        random.seed (3141)
        for i in range (1000):
            k = random.randint (0, 100000)
            t0[k] = None
            t0.verify()

if __name__ == '__main__':
    unittest.main()
