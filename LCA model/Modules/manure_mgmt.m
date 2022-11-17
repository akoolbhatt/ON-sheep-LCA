% © Akul Bhatt, 2021
%%% CH4 FROM MANURE MANAGEMENT %%%
%---------------------------------------------------------------

% Volatile Solids excretion, VS [kg/head/day] (ECCC, FAO method)
S.VS = ( (S.feed_per_head * 18.45).*((1 - S.DE) + S.UE) ) * ...
       (1 - S.ASH) / 18.45;


% Combine MCF into array:
S.MCF = [S.MCF_liquid, S.MCF_solid, S.MCF_drylot, S.MCF_PRP];

% Weighted MCF based on inputted MS practices:
S.MCF_weighted = sum(S.MS .* S.MCF);

% Annual CH4 emissions from manure management [kg CH4/head/year]
S.manure_CH4 = 0.67 * 365 * S.Bo * S.MCF_weighted * S.VS;
%---------------------------------------------------------------


%%% Nitrogen Balance %%%
%---------------------------------------------------------------
% Defaule EC(2018) Annual N excretion rate per animal, Nex [kg N/head/year]
S.Nex = S.N_excr * (S.BW / 1000) * 365;

% Total N consumed annually through feed per head [kg N/head/year]
S.N_in = 365 * [sum(S.N_feed .* S.feed_adult_ewe), ...
                sum(S.N_feed .* S.feed_adult_ram), ...
                sum(S.N_feed .* S.feed_lamb_ewe), ...
                sum(S.N_feed .* S.feed_lamb_ram)];                     
                      
% N outputted per head in terms of products [kg N/head/year]
S.N_out_meat = S.N_meat * [S.LW_per_ewe, S.LW_per_ram, ...
                         S.LW_per_lamb, S.LW_per_lamb]; % From meat

S.N_out_wool = S.N_wool * S.wool_per_head; % From wool

S.N_out_milk = S.N_milk * [S.milk_per_ewe, 0, 0, 0]; % From milk

% N outputted per head from all products [kg N/head/year]
S.N_out = S.N_out_meat + S.N_out_wool + S.N_out_milk; 

% Annual N excreted per head [kg N/head/year]
S.Nex = S.N_in - S.N_out;
%---------------------------------------------------------------


%%% DIRECT N2O FROM MANURE MANAGEMENT %%%
%---------------------------------------------------------------
% Assuming that lambs are weaned after 6 months: 
% Multiply lambs' Nex by 6/12:
S.Nex(3) = S.Nex(3) * 6/12;
S.Nex(4) = S.Nex(4) * 6/12;

% Combine EF3s into array
S.EF3 = [S.EF3_liquid, S.EF3_solid, S.EF3_drylot, S.EF3_PRP];

% Weighted direct N2O emisison EF3 based on inputted MS:
S.EF3_weighted = sum (S.MS .* S.EF3);

% Annual direct N2O emissions [kg N2O/head/year]
S.manure_direct_N2O = 44/28 * S.Nex * S.EF3_weighted;
%---------------------------------------------------------------



%%% INDIRECT N2O FROM MANURE MANAGEMENT - VOLATIZATION %%%
%---------------------------------------------------------------
% Combine FracGas into array
S.FracGas = [S.FracGas_liquid, S.FracGas_solid, ...
             S.FracGas_drylot, S.FracGas_PRP];

% Weighted FracGas based on inputted MS
S.FracGas_weighted = sum (S.MS .* S.FracGas);

% Indirect emissions of N2O from volatization [kg N2O/head/year]
S.manure_N2O_vol = 44/28 * S.Nex * S.FracGas_weighted * S.EF4;
%---------------------------------------------------------------



%%% INDIRECT N2O FROM MANURE MANAGEMENT - LEACHING %%%
%---------------------------------------------------------------
% Combine FracLeach into array
S.FracLeach = [S.FracLeach_liquid, S.FracLeach_solid, ...
               S.FracLeach_drylot, S.FracLeach_PRP];

% Weighted FracLeach based on inputted MS
S.FracLeach_weighted = sum (S.MS .* S.FracLeach);

% Indirect emissions of N2O from leaching / runoff [kg N2O/head/year]
S.manure_N2O_leach = 44/28 * S.Nex * S.FracLeach_weighted * S.EF5;
%---------------------------------------------------------------

