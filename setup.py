from setuptools import setup, find_packages, Extension
from Cython.Distutils import build_ext

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
