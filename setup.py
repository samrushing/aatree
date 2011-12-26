from setuptools import setup, find_packages, Extension
from Cython.Distutils import build_ext

import sys
# see http://www.velocityreviews.com/forums/t693861-cython-setuptools-not-working-with-pyx-only-with-c-files.html
try:
    import Cython
    # may need to work around setuptools bug by providing a fake Pyrex
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "fake_pyrex"))
except ImportError:
    pass

setup (
    name             = 'aatree',
    version          = '0.1',
    description      = 'simplified variant of the red-black balanced binary search tree',
    author           = "Sam Rushing",
    packages         = find_packages(),
    ext_modules      = [Extension('aatree.aa', ['aatree/aa.pyx'])],
    cmdclass         = {'build_ext': build_ext},
    install_requires = ['cython>=0.15'],
    url               = 'http://github.com/samrushing/aatree/',
    download_url      = "http://github.com/samrushing/aatree/tarball/master#egg=aatree-0.1",
    )
