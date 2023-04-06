

## Settings - Ankle and foot model

- **fixed_knee**: position of knee axis fixed in anatomical position (default is 1) [boolean]
- **AchillesTendonScaleFactor**: scale factor of normalised stiffness of Achilles tendon (default is 0.5) [double]
- **TricepsFMoScale**: scale factor of triceps surae maximal isometric force [double]
- **passiveFiberForceShift**: shift passive force-length of muscle fibre. e.g. -0.1 shifts towards 10% shorter optimal fibre lengths [double]

**S.Foot**

- **Model**: foot joints identifier [string]
    *mtp*: 2-segment with oblique mtp axis
    *mtppin*: 2-segment with sagittal mtp axis
    *mtj*: 3-segment with oblique mtp axis and sagittal midtarsal axis
    *mtjc4*: 3-segment with oblique mtp axis and midtarsal axis orientation 4 (substitute 4 for 1..5)
- **Scaling**: scaling method. *default* for uniform scaling, *custom* for non-uniform [string]
- **MTparams**: adapted muscle-tendon parameters. *MTc5* indicates midfoot insertions are corrected for non-uniform scaling [string]

*MTP*

- **mtp_muscles**: mtp joint is actuated by muscles [boolean]
- **kMTP**: passive mtp stiffness, in Nm/rad (default is 25) [double]
- **dMTP**: passive mtp damping, in Nms/rad (default is 2) [double]
- **mtp_tau_pass**: apply coordinate limit torque to mtp [boolean]
- **mtp_M_PF**: apply plantar fascia stiffness on mtp joint in 2-segment model [boolean]

*midtarsal*

- **mtj_muscles**: midtarsal joint is actuated by muscles [boolean]
- **MT_li_nonl**: use nonlinear midtarsal ligament angle-moment [boolean]
- **mtj_stiffness**: identifier of nonlinear ligament angle-moment [string]
    *MG_exp5_table*: look-up table based on contributions of individual ligaments, as explained in the paper
    *signed_lin*: uses kMT_li for negative angles and kMT_li2 for positive angles
- **kMT_li**: stiffness, in Nm/rad [double]
- **kMT_li2**: stiffness for positive angles in case of signed_lin [double]
- **dMT**: damping [double]

*plantar fascia*

- **PF_stiffness**: force-length. Options are *Natali2010*, *none*, *linear*, *Gefen2002*, *Song2011* [string]
- **PF_sf**: scale factor for force [double]
- **PF_slack_length**: slack length [double]

*plantar intrinsic muscle*

- **FDB**: Flexor Digitorum Brevis. *0*: not included, *2*: included [double]
- **FDB_lMo**: optimal fibre length, in m [double]
- **FDB_lTs**: tendon slack length, in m [double]
- **FDB_shift**: shift passive force-length of muscle fibre. e.g. -0.1 shifts towards 10% shorter optimal fibre lengths [double]
- **FDB_sf_FMo**: scale factor for maximal isometric force [double]
- **FDB_nerveBlock**: contrain activation to lower bound

*contact spheres*

- **contactStiffnessFactor**: contact stiffness in MPa [double]
- **contactGeometryVersion**: contact sphere configuration, arbitrary number [double]
- **contactSphereOffsetY**: y-offset of all contact spheres, arbitrary number [double]
- **contactSphereOffset45Z**: z-offset of contact spheres 4 and 5, in m [double]
- **contactSphereOffset1X**: x-offset of contact sphere 1, in m [double]

## Settings - Generic

**Subject**

- **subject**: subject identifier (default is Fal_s1, i.e. Falisse et al. subject 1) [string]
- **v_tgt**: imposed speed (default is 1.33) [double]
- **mass**: mass of the subject in kg (default is 62) [double]

**File management**

- **ResultsRepo**: path to folder above ResultsFolder [string]
- **ResultsFolder**: folder the save the results [string]
- **suffixCasName**: will be added to the structured savename of the folder with casadi functions [string]
- **suffixName**: will be added to the structured savename of the results [string]

**Simulated motion**

- **Symmetric**: simulate symmetric motion (i.e. half a gait cycle), default is true [boolean]
- **Periodic**: simulate a periodic motion (i.e. full gait cycle), default is false [boolean]

**Settings formulation and solving NLP**

- **N**: number of mesh intervals (default is 100) [double]
- **NThreads**: number of threads for parallel computing (default is 4) [double]
- **linear_solver**: default is mumps [string]
- **tol_ipopt:** tolerance of ipopt solver (default is 4) [double]
- **parallelMode**: default is thread

**Weights**

- **W.E**: weight metabolic energy rate (default is 500)
- **W.Ak**: weight joint accelerations (default is 50000)
- **W.ArmE**: weight arm excitations (default is 10^6)
- **W.passMom**: weight passive torques (default is 1000)
- **W.A**: weight muscle activations (default is 2000)
- **W.exp_E**: power metabolic energy (default is 2)
- **W.u**: weight on excitations arms actuators (default is 0.001)

**Initial guess**

- **IGmodeID**: initial guess based on (1) walking motion, (2) running motion, (3) previous solution in the *Results* folder, (4) previous solution in the *./IG/data folder* default is (1)

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

- **Constr.calcn:** minimal distance between calcneneus (origin) in the transversal plane. (default is 0.09m) [double]
- **Constr.toes:** minimal distance between toes (origin) in the transversal plane. (default is 0.09m) [double]
- **Constr.tibia:** minimal distance between tibia(?s) (origin) in the transversal plane. (default is 0.09m) [double]

