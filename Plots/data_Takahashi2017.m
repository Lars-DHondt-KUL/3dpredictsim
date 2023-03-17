
% results from DOI:10.1038/s41598-017-15218-7
ref_pos_m = [0.006,0.012,0.042,0.185];
ref_pos_std = [0.004,0.005,0.012,0.028];
ref_neg_m = [-0.013,-0.095,-0.125,-0.197];
ref_neg_std = [0.004,0.031,0.026,0.040];
ref_net_m = [-0.006,-0.083,-0.083,-0.012];
ref_net_std = [0.005,0.032,0.021,0.054];

% order: hallux, forefoot, hindfoot, shank

%%

Bar4 = 0.13162929745889385;
Bar5 = 0.07010463378176385;

Bar6 = -0.03913303437967117;
Bar7 = -0.06801195814648732;


Bar8 = 0.06173393124065768;
Bar9 = 0.029925261584454382;

Bar10 = -0.06257100149476834;
Bar11 = -0.10191330343796715;


Bar12 = 0.017369207772795187;
Bar13 = 0.07763826606875932;

Bar14 = -0.011928251121076261;
Bar15 = -0.06005979073243649;

%
mtj_p_m = (Bar4+Bar5)/2;
mtj_p_s = (Bar4-Bar5)/2;

mtj_n_m = (Bar6+Bar7)/2;
mtj_n_s = (Bar6-Bar7)/2;

mtj_t_m = (Bar12+Bar13)/2;
mtj_t_s = (Bar12-Bar13)/2;


mtjff_p_m = (Bar8+Bar9)/2;
mtjff_p_s = (Bar8-Bar9)/2;

mtjff_n_m = (Bar10+Bar11)/2;
mtjff_n_s = (Bar10-Bar11)/2;

mtjff_t_m = (Bar14+Bar15)/2;
mtjff_t_s = (Bar14-Bar15)/2;

%%

Bar0 = 0.22099447513812154;
Bar1 = 0.15331491712707182;
Bar2 = -0.0766574585635359;
Bar3 = -0.1595303867403315;
Bar4 = 0.13052486187845305;
Bar5 = 0.00828729281767962;

ankle_p_m = (Bar0+Bar1)/2;
ankle_p_s = (Bar0-Bar1)/2;

ankle_n_m = (Bar2+Bar3)/2;
ankle_n_s = (Bar2-Bar3)/2;

ankle_t_m = (Bar4+Bar5)/2;
ankle_t_s = (Bar4-Bar5)/2;



