Nominal models
================

This folder contains the nominal 2- and 3-segment foot models. We used models with the knee axis fixed in anatomical position, consistent with previous work [2]. Models with translating knee axis are also provided.
The models use geometry files distributed with OpenSim, [foot bone geometry files based on CT scan [3]](https://simtk.org/docman/?group_id=1020). We adapted the original calacneus geometry files to reflect our different definition of the segment origin.



## Alternative midtarsal joint axis orientations

The nominal 3-segment foot model uses midtarsal joint axis orientation 4. 
Replace the TransformAxis of rotation1 to use another joint axis.

axis orientation 1
- right: -0.68143 -0.33708 0.64964
- left:   0.68143  0.33708 0.64964

axis orientation 2
- right: -0.35789 -0.34528 0.86758
- left:   0.35789  0.34528 0.86758

axis orientation 3
- right: 0.020132 -0.30093 0.95344
- left: -0.020132  0.30093 0.95344

axis orientation 4
- right: 0.39509 -0.21075 0.89414
- left: -0.39509  0.21075 0.89414

axis orientation 5
- right: 0.7099 -0.088495 0.69872
- left: -0.7099  0.088495 0.69872


## References

1. L. D’Hondt, F. D. Groote, and M. Afschrift, “A dynamic foot model for predictive simulations of gait reveals causal relations between foot structure and whole body mechanics.” bioRxiv, p. 2023.03.22.533790, Mar. 24, 2023. doi: 10.1101/2023.03.22.533790.

2. A. Falisse, M. Afschrift, and F. D. Groote, “Modeling toes contributes to realistic stance knee mechanics in three-dimensional predictive simulations of walking,” PLOS ONE, vol. 17, no. 1, p. e0256311, Jan. 2022, doi: 10.1371/journal.pone.0256311.

3. T. M. Malaquias et al., “Extended foot-ankle musculoskeletal models for application in movement analysis,” Computer methods in biomechanics and biomedical engineering, vol. 20, no. 2, pp. 153–159, 2017.




