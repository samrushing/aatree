from setuptools import setup, find_packages, Extension
from Cython.Distutils import build_ext

setup (
    name             = 'aatree',
    version          = '0.1',
    packages         = find_packages(),
    ext_modules      = [Extension('aatree.aa', ['aatree/aa.pyx'])],
    cmdclass         = {'build_ext': build_ext},
    install_requires = ['cython>=0.15'],
    author           = "Sam Rushing",
    )
