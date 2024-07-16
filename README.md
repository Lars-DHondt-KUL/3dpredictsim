Predictive simulations of human gait
============

This repository contains all code and models used to generate the simulations discussed in: L. D’Hondt, F. D. Groote, and M. Afschrift, “A dynamic foot model for predictive simulations of human gait reveals causal relations between foot structure and whole-body mechanics,” PLOS Computational Biology, vol. 20, no. 6, p. e1012219, Jun. 2024, doi: 10.1371/journal.pcbi.1012219.



## Running predictive simulations
The code in this repository is tailored to simulating gait for specific models. 
If you want to use predictive simulations for your own research, consider using [PredSim](https://github.com/KULeuvenNeuromechanics/PredSim) instead.

### Dependencies
Minimally required software
* [CasADi](https://web.casadi.org/get/) version 3.5.5
* MATLAB (code is tested for R2021b)

### Reproducing the results and figures shown in the paper

1. Open `./ReproduceResultsPaper.m` and set `casadiPath = ` to your CasADi download folder.
2. Run `./ReproduceResultsPaper.m`.


### Running predictive simulations

**1. Generate functions that describe model dynamics.** These functions are included for all simulations we used for the paper and supplementary material. *Try skipping to step 2*, and only perform step 1 if you get an error about missing files.
    
* Use [opensimAD](https://github.com/Lars-DHondt-KUL/opensimAD) to generate a function describing the skeletal and contact dynamics of your model, and *manually* place the resulting files in `./ExternalFunctions/`.
* Run `./ConvertOsimModel/PrepareOptimization.m` to read muscle parameters and generate polynomial approximations of muscle-tendon and plantar fascia lengths and momentarms in function of joint angles.
* Run `./FootModel/fitPlantarLigamentMoment.m` to generate a look-up table with midtarsal joint moment due to ligaments. It will be added to the indicated folder with polynomials. 

**2. Run simulation**

You can use a script based on `./ReproduceResultsPaper.m` (or simply add more code blocks there).

a. Get the settings for the nominal model. 
```matlab
[S] = getSettingsNominalModel(4);
```
Input argument `4` will return settings for 4-segment foot model, `3` for 3-segment.

b. Overwrite settings you want to change. See [list of settings](SettingsOverview.md).

c. Run simulation
```matlab
PredSim(S,1,1,0);
```


Alternatively, you can select all settings in `./Main.m`, then run that script.




## Nominal models
This implementation reads information from different .osim model files and combines it in matlab, since this provided flexibility during development. 
The nominal models can be found in `./OpenSimModel/Nominal models/`

