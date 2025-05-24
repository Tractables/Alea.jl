from setuptools import find_packages, setup

setup(
    name='benchtool',
    packages=find_packages(include=['benchtool']),
    version='0.1.0',
    description='Benchmarking Tool for Property-Based Testing',
    author='TODO',
    license='MIT',
    install_requires=['pandas>=1.4.2', 'plotly>=5.8.2'],
)
