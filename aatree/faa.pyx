# -*- Mode: Cython; indent-tabs-mode:nil -*-

# see:
#  http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_andersson.aspx
#  http://en.wikipedia.org/wiki/AA_tree

# this is a modified, pure-functional version of aa.pyx.

from libc.stdint cimport uint32_t, uint16_t, uint8_t

cdef class aa_node:
    cdef readonly uint8_t level
    cdef readonly aa_node l, r
    cdef readonly object key, val
    def __cinit__ (self, int level, aa_node l, aa_node r, object key, object val):
        self.level = level
        self.l = l
        self.r = r
        self.key = key
        self.val = val

    cdef aa_node copy (self):
        if self is tree_nil:
            return self
        else:
            return aa_node (self.level, self.l, self.r, self.key, self.val)

import sys
W = sys.stderr.write

# this global node acts as a sentinel
cdef aa_node tree_nil
tree_nil = aa_node (0, tree_nil, tree_nil, None, None)
tree_nil.l = tree_nil
tree_nil.r = tree_nil

# non-recursive skew and split

cdef aa_node skew (aa_node n):
    if n.level != 0 and n.l.level == n.level:
        return aa_node (
            n.level,
            n.l.l,
            aa_node (n.level, n.l.r, n.r, n.key, n.val),
            n.l.key,
            n.l.val,
        )
    else:
        return n

cdef aa_node split (aa_node n):
    if n.level != 0 and n.r.r.level == n.level:
        return aa_node (
            n.r.level + 1,
            aa_node (n.level, n.l, n.r.l, n.key, n.val),
            n.r.r,
            n.r.key,
            n.r.val,
        )
    else:
        return n

# useful for a multimap
cdef aa_node tree_insert_multi (aa_node n, object key, object val):
    cdef aa_node n0
    if n.level == 0:
        return aa_node (1, tree_nil, tree_nil, key, val)
    else:
        if key < n.key:
            n0 = aa_node (n.level, tree_insert_multi (n.l, key, val), n.r, n.key, n.val)
        else:
            n0 = aa_node (n.level, n.l, tree_insert_multi (n.r, key, val), n.key, n.val)
        return split (skew (n0))

# this will do an insert if the key is not present.
# otherwise, it will return a new root path to a modified node.
cdef tree_update (aa_node n, object key, object val):
    cdef aa_node n0, l, r
    cdef bint inserted
    if n.level == 0:
        n0 = aa_node (1, tree_nil, tree_nil, key, val)
        return n0, True
    else:
        if key < n.key:
            l, inserted = tree_update (n.l, key, val)
            n0 = aa_node (n.level, l, n.r, n.key, n.val)
        elif key > n.key:
            r, inserted = tree_update (n.r, key, val)
            n0 = aa_node (n.level, n.l, r, n.key, n.val)
        else:
            n0 = n.copy()
            n0.val = val
            inserted = False
        if inserted:
            return split (skew (n0)), True
        else:
            return n0, False

# the Stark Fist of Removal.  This class is just a placeholder for the two static/global variables
#  used in the deletion algorithm.
cdef class fist:
    cdef aa_node heir
    cdef aa_node item
    cdef object key, val
    def __cinit__ (self):
        self.heir = tree_nil
        self.item = tree_nil

# This is based on julienne's version of anderson's deletion algorithm.
#  I found it a little easier to reason about (w.r.t. immutability).

# XXX KeyError?    

cdef aa_node tree_remove (fist self, aa_node root, object key):
    cdef aa_node root0
    cdef int compare
    # search down the tree
    if root is not tree_nil:
        compare = root.key < key
        self.heir = root
        if compare == 0:
            self.item = root.copy()
            root0 = self.item
            root0.l = tree_remove (self, root.l, key)
        else:
            root0 = aa_node (root.level, root.l, tree_remove (self, root.r, key), root.key, root.val)
    else:
        root0 = root
    if root is self.heir:
        # at the bottom, remove
        if self.item is not tree_nil and self.item.key == key:
            self.key = self.item.key
            self.val = self.item.val
            self.item.key = self.heir.key
            self.item.val = self.heir.val
            self.item = tree_nil
            # here we differ from AA's algorithm.
            if root0.r is tree_nil:
                return root0.l
            else:
                return root0.r
        else:
            return root0
    else:
        # not at the bottom, rebalance
        if root0.l.level < root0.level - 1 or root0.r.level < root0.level - 1:
            root0.level -= 1
            if root0.r.level > root0.level:
                root0.r = root0.r.copy()
                root0.r.level = root0.level
            root0 = skew (root0)
            root0.r = skew (root0.r)
            root0.r.r = skew (root0.r.r.copy())
            root0 = split (root0)
            root0.r = split (root0.r)
            return root0
        else:
            return root0

def walk (aa_node n):
    if n is not tree_nil:
        for x in walk (n.l):
            yield x
        yield n
        for x in walk (n.r):
            yield x

def walk_depth (aa_node n, int depth=0):
    cdef aa_node x
    cdef int d
    if n is not tree_nil:
        for x, d in walk_depth (n.l, depth + 1):
            yield x, d
        yield n, depth
        for x, d in walk_depth (n.r, depth + 1):
            yield x, d

def verify (aa_node t):
    cdef aa_node n
    cdef int h
    h = t.level
    for n in walk (t):
        assert n.l.level != n.level
        assert not (n.level == n.r.level and n.level == n.r.r.level)

def dump (t):
    W ('---\n')
    for n, d in walk_depth (t, 0):
        W ('%s%4d %r\n' % ('  ' * d, n.level, n.key))

cdef class PersistentMap:

    cdef public aa_node root
    cdef public uint32_t length

    def __init__ (self):
        self.root = tree_nil

    def __len__ (self):
        return self.length

    def copy (self):
        m = PersistentMap()
        m.root = self.root
        m.length = self.length
        return m

    cdef aa_node _search (self, object key):
        cdef aa_node search = self.root
        while 1:
            if search == tree_nil:
                return tree_nil
            elif search.key == key:
                return search
            elif search.key < key:
                search = search.r
            else:
                search = search.l

    def __contains__ (self, object key):
        cdef aa_node probe = self._search (key)
        return probe is not tree_nil

    def __iter__ (self):
        return walk (self.root)

    def __getitem__ (self, object key):
        cdef aa_node probe = self._search (key)
        if probe is tree_nil:
            raise KeyError (key)
        else:
            return probe.val

    def __delitem__ (self, object key):
        cdef fist f
        f = fist()
        self.root = tree_remove (f, self.root, key)
        self.length -= 1

    def pop (self, object key):
        cdef fist f
        f = fist()
        self.root = tree_remove (f, self.root, key)
        self.length -= 1
        return f.val

    def __setitem__ (self, object key, object val):
        cdef bint inserted
        self.root, inserted = tree_update (self.root, key, val)
        if inserted:
            self.length += 1

    def verify (self):
        verify (self.root)

    def dump (self):
        for n, d in walk_depth (self.root, 0):
            W ('%s%4d %r:%r\n' % ('  ' * d, n.level, n.key, n.val))
        
