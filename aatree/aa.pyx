# -*- Mode: Cython -*-

# see:
#  http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_andersson.aspx
#  http://en.wikipedia.org/wiki/AA_tree

from libc.stdint cimport uint32_t

cdef class aa_node:
    cdef readonly int level
    cdef readonly aa_node left, right
    cdef readonly object key, val
    def __cinit__ (self, int level, aa_node left, aa_node right, object key, object val):
        self.level = level
        self.left = left
        self.right = right
        self.key = key
        self.val = val

# this global node acts as a sentinel
cdef aa_node tree_nil
tree_nil = aa_node (0, tree_nil, tree_nil, None, None)

cdef aa_node tree_skew (aa_node root):
    cdef aa_node save
    if root.level != 0:
        if root.left.level == root.level:
            save = root
            root = root.left
            save.left = root.right
            root.right = save
        root.right = tree_skew (root.right)
    return root

cdef aa_node tree_split (aa_node root):
    cdef aa_node save
    if root.right.right.level == root.level and root.level != 0:
        save = root
        root = root.right
        save.right = root.left
        root.left = save
        root.level += 1
        root.right = tree_split (root.right)
    return root

cdef aa_node tree_insert (aa_node root, object key, object val):
    cdef aa_node new_node
    if root == tree_nil:
        return aa_node (1, tree_nil, tree_nil, key, val)
    elif root.key < key:
        root.right = tree_insert (root.right, key, val)
        return tree_split (tree_skew (root))
    else:
        root.left = tree_insert (root.left, key, val)
        return tree_split (tree_skew (root))

cdef aa_node tree_remove (aa_node root, object key):
    cdef aa_node heir
    if root != tree_nil:
        if root.key == key:
            if root.left != tree_nil and root.right != tree_nil:
                heir = root.left
                while heir.right != tree_nil:
                    heir = heir.right
                root.key = heir.key
                root.val = heir.val
                root.left = tree_remove (root.left, root.key)
            elif root.left == tree_nil:
                root = root.right
            else:
                root = root.left
        elif root.key < key:
            root.right = tree_remove (root.right, key)
        else:
            root.left = tree_remove (root.left, key)
    if (root.left.level < (root.level - 1) or
        root.right.level < (root.level - 1)):
        root.level -= 1
        if root.right.level > root.level:
            root.right.level = root.level
        root = tree_split (tree_skew (root))
    return root
            
def walk (aa_node n):
    if n.left.level > 0:
        for x in walk (n.left):
            yield x
    yield n
    if n.right.level > 0:
        for x in walk (n.right):
            yield x


cdef class multimap:

    cdef public aa_node root
    cdef public uint32_t length

    def __init__ (self):
        self.root = tree_nil

    def __iter__ (self):
        return walk (self.root)

    def __getitem__ (self, object key):
        cdef aa_node search = self.root
        while 1:
            if search == tree_nil:
                raise KeyError (key)
            elif search.key == key:
                break
            elif search.key < key:
                search = search.right
            else:
                search = search.left
        return search.val

    def insert (self, object key, object val):
        self.root = tree_insert (self.root, key, val)
        self.length += 1

    def __delitem__ (self, object key):
        # XXX how do we know if it's been removed?
        self.root = tree_remove (self.root, key)

    #def __setitem__ (self, object key, object val):
    #    not useful in a multimap
