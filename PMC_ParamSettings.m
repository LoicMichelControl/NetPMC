
   aa_1 = 1; %2*5*1e-2;
   bb_1 = 1; %2*5*1e-2;


   Kp_stab = 1e-2; %1e-2;
   Ki_stab = 100; %1e-2;

   aa_2 = 0.1 * Kp_stab;
   bb_2 = 0.1 * Ki_stab;

   aa_3 = 1e-1;
   bb_3 = 100;

   aa_4 = 5*1e-3;
   bb_4 = 5*1e-3;

   aa_5 = 1e-2;
   bb_5 = 100;


            PMC_Kp_1 = aa_1; %1e-3;
            PMC_Kint_1 = bb_1; %1e-3;
            PMC_K_alpha_1 = 1e2;
            PMC_K_beta_1 = 10;
            PMC_FinalScale_1 = 1e5;


            PMC_Kp_2 = 10;
            PMC_Kint_2 = 10;
            PMC_K_alpha_2 = 1e4;
            PMC_K_beta_2 = 10;
            PMC_FinalScale_2 = 1e+03;


            PMC_Kp_3 = aa_4;
            PMC_Kint_3 = bb_4;
            PMC_K_alpha_3 = 1e2;
            PMC_K_beta_3 = 10;
            PMC_FinalScale_3 = 1e5;