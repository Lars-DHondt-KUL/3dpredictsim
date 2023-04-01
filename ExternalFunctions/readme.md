ExternalFunctions
==============

This folder contains [compiled libraries that can be loaded into matlab as CasADi external functions](https://web.casadi.org/docs/#importing-a-function-with-external).
We use external functions to describe rigid-body and contact dynamics. All files in this folder were generated with [opensimAD](https://github.com/Lars-DHondt-KUL/opensimAD).
For each model, there are three files:
- `F_*.dll` The library containing the function.
- `F_*.cpp` Code used to generate the source code for the library.
- `F_*_IO.mat` Indices to relate inputs and outputs of the function to coordinates, ground reaction forces, etc.

Reference publication: 
Falisse A, Serrancolí G, et al. (2019) Algorithmic differentiation improves the computational efficiency of OpenSim-based trajectory optimization of human movement. PLoS ONE 14(10): e0217730. https://doi.org/10.1371/journal.pone.0217730
