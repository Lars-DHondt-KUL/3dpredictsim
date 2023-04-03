

#### Settings- Required

- **PolyFolder**: Folder with the surrogate model for the muscle-tendon length and moment arms (from step 1 of the section "Create all input for the simulations"). This path to the folder is relative to the folder (./Polynomials) [string]
- **CasadiFunc_Folders**: Name of the folder with the casadifunctions (exported in step 2 of the section "Create all input for the simulations"). This path to the folder is relative to the folder (./CasadiFunctions) [string]
- **v_tgt**: imposed walking speed [double]
- **ModelName**: select type of musculoskeletal model. Currently the two options are (1) Gait92 or (2) Rajagopal [string] 
- **Mass**: mass of the subject in kg [double]
- **ExternalFunc:** Name of the .dll file used in the optimization (used for solving inverse dynamics). This file should be in the folder *./ExternalFunctions*. See step three of the section "Create all input for the simulations". [string].
- **ExternalFunc2:** Name of the .dll file used for post processing. This file should be in the folder *./ExternalFunctions*. See step three of the section "Create all input for the simulations" [string]
- **ResultsFolder**: folder the save the results [string]
- **Savename**: the of the results file [string]



#### Settings - optional

**Simulated motion**

- **Symmetric**: simulate symmetric motion (i.e. half a gait cycle), default is true [boolean]
- **Periodic**: simulate a periodic motion (i.e. full gait cycle), default is false [boolean]

**Settings formulation and solving NLP**

- **N**: number of mesh intervals (default is 50) [double]
- **NThreads**: number of threads for parallel computing (default is 2) [double]
- **linear_solver**: default is mumps [string]
- **tol_ipopt:** tolerance of ipopt solver
- **parallelMode**: default is thread

**Weights **

- **W.E**: weight metabolic energy rate (default is 500)
- **W.Ak**: weight joint accelerations (default is 50000)
- **W.ArmE**: weight arm excitations (default is 10^6)
- **W.passMom**: weight passive torques (default is 1000)
- **W.A**: weight muscle activations (default is 2000)
- **W.exp_E**: power metabolic energy (default is 2)
- **W.Mtp**: weight mtp excitations (default is 10^6)
- **W.u**: weight on excitations arms actuators (default is 0.001)
- **W.Lumbar: ** weight on miniizing lumbar activations (in Rajagopal model) (default is 10^5)

**Initial guess** (Note: I should improve this in the future)

- **IGmodeID**: initial guess based on (1)walking motion, (2) running motion, (3) previous solution in the *Results* folder, (4) previous solution in the *./IG/data folder* default is (1)

- **IGsel**: (1) quasi random initial guess (2) data-based initial guess (default is 2)

- **IKfile_guess**: relative path to IK file used for initial guess (used when IGsel = 2 and IGmodeID is 1 or 2). Default is *OpenSimModel\IK_Guess_Default.mat*

- **savename_ig**: name of the IK file used for initial guess (used when IGmodelID is 4). This file should be in *./IG/data folder*. [string]

- **ResultsF_ig:** name of Folder with IK file for setting *savename_ig* (see above) when IGmodelID is 3 [string].

- **IG_PelvisY**: height of the pelvis in the quasi-random initial guess (in m) [double]

**Adapting bounds**

- **IKfile_Bounds**: relative path to IK file used to determine bounds (i.e. 3 times ROM in IK file for all DOFs). Default is *OpenSimModel\IK_Guess_Default.mat*
- **Bounds.ActLower**: lower bound on all muscle activations
- **Bounds.ActLowerHip**: lower bound on activation of the hip muscles
- **Bounds.ActLowerKnee**: lower bound on activation of the knee muscles
- **S.Bounds.ActLowerAnkle**: lower bound on activation of the ankle muscles

**Kinematic constraints**

- **Constr.calcn:** minimal distance between calcneneus (origin) in the transversal plane. default is 0.09m [double]
- **Constr.toes:** minimal distance between toes (origin) in the transversal plane. default is 0.09m [double]
- **Constr.tibia:** minimal distance between tibia(?s) (origin) in the transversal plane. default is 0.09m [double]

**Exoskeleton control **

- **DataSet**: name of the folder with exoskeleton assistance profile (saved in the folder *./Data*) with a .mat file named *torque_profile.mat*. This mat file should contain the variables *time* and *torque* with the torque profile for one full stride.
- **ExoBool:** Boolean to select if you want to include the torque profile (i.e. use exoskeleton)
- **ExoScale:** scale factor for the torque profile.
