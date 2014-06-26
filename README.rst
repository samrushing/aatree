
AA Trees
========

The AA_ tree is a balanced binary search tree derived from red-black_
trees.  A simplification of the constraints on red-black trees makes
the algorithms, even deletion, much simpler.  Performance is
comparable - the slightly higher number of rotations is offset by the
faster code.

Implementation
--------------

This implementation is written in Cython_, and was written as an
emulation of the STL multimap.  Things you might want to tweak when
using this code:

  * define __setitem__ and insert to allow only one copy of each key (making it act like a map rather than a multimap)
  * change aa_node.key to be a base C type like uint64_t, avoiding the overhead of calling Python's comparison engine.

Both modules are based on the very useful tutorial_ written by Julienne Walker.

Functional/Persistent Version
-----------------------------

The 'faa.pyx' module implements a pure-functional/persistent_ map.
There are many advantages to persistent data structures, and varied
uses.  The basic idea is that you may have multiple versions of the
same map, each sharing the vast majority of their structure.

For more info, please see Chris Okasaki's blog, thesis_, or book_.

.. _Cython: http://cython.org/
.. _tutorial: http://eternallyconfuzzled.com/tuts/datastructures/jsw_tut_andersson.aspx
.. _AA: http://en.wikipedia.org/wiki/AA_tree
.. _red-black: http://en.wikipedia.org/wiki/Red-black_tree
.. _persistent: http://en.wikipedia.org/wiki/Persistent_data_structure
.. _blog: http://okasaki.blogspot.com/search/label/functional%20programming
.. _thesis: http://www.cs.cmu.edu/~rwh/theses/okasaki.pdf
.. _book: http://www.amazon.com/Purely-Functional-Structures-Chris-Okasaki/dp/0521663504
