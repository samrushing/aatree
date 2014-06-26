
from setuptools import setup, find_packages
from Cython.Build import cythonize

setup (
    name             = 'aatree',
    version          = '0.1',
    description      = 'simplified variant of the red-black balanced binary search tree',
    author           = "Sam Rushing",
    packages         = find_packages(),
    ext_modules      = cythonize (['aatree/aa.pyx', 'aatree/faa.pyx']),
    install_requires = ['cython>=0.20.1'],
    url               = 'http://github.com/samrushing/aatree/',
    download_url      = "http://github.com/samrushing/aatree/tarball/master#egg=aatree-0.1",
    )
