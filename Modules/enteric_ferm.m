% © Akul Bhatt, 2021
% Calculate parameters related to gross energy and enteric ferm...

%NOTE: For subsequent calcs, use this 1x4 array format:
% [adult ewe, adult ram, lamb ewe, lamb ram]

%Body weights per head [kg/head]
S.BW = [S.BW_ewe, S.BW_ram, S.BW_lamb_ewe, S.BW_lamb_ram];


%%% NET ENERGY FOR MAINTENANCE, NE_m %%%
%---------------------------------------------------------------
% Combine Cfi into array
S.Cfi_0 = [S.Cfi_0_adult, S.Cfi_0_adult, S.Cfi_0_lamb, S.Cfi_0_lamb]; % MJ/kg/day

%Cfi increases by 15% for castrated males; modify males' Cfi to reflect that:
S.Cfi_0(2) = S.Cfi_0(2) * (1.15 - 0.15 * S.castrated_ram); % Adult rams
S.Cfi_0(4) = S.Cfi_0(4) * (1.15 - 0.15 * S.castrated_ram_lamb); % Lamb rams

% Modify Cfi based on ambient temperature:
S.Cfi = S.Cfi_0 + 0.0048 * (20 - S.Tamb);

% Net energy for maintenance, NE_m [MJ/head/day]:
S.NE_m = S.Cfi .* S.BW .^ 0.75;
%---------------------------------------------------------------


%%% NET ENERGY FOR ACTIVITY, NE_a %%%
%---------------------------------------------------------------
% Combine in array; to be used in subsequent calcs
S.Ca_activity = [S.Ca_housed_ewe, S.Ca_flat, S.Ca_hilly, S.Ca_fatten];

% Final weighted activity coefficient [MJ/kg/day]
S.Ca = sum(S.P_activity .* S.Ca_activity);

%Net energy for anaimal activity, NE_a [MJ/head/day]
S.NE_a = S.Ca * S.BW;
%---------------------------------------------------------------


%%% NET ENERGY FOR GROWTH, NE_g %%%
%---------------------------------------------------------------
% Combine 'a' and 'b' into array (weighted based on castrated males)
S.a = [0, 0, S.a0_female, ...
     S.a0_intact + S.castrated_ram_lamb * (S.a0_castr - S.a0_intact)];
 
S.b = [0, 0, S.b0_female, ...
     S.b0_intact + S.castrated_ram_lamb * (S.b0_castr - S.b0_intact)]; 

% Weight gain from weaning to 1 year age;
S.WG = [0, 0, S.BW_lamb_ewe - S.BW_weaning, S.BW_lamb_ram - S.BW_weaning];

% Net energy for growth, NE_g [MJ/head/day]
S.NE_g = zeros(1,4); %Initialize NE_g
for i = 1:4
    S.NE_g(i) = S.WG(i) * (S.a(i) + 0.5*S.b(i)*(S.BW_weaning + S.BW(i))) / 365;
end
%--------------------------------------------------------------



%%% NET ENERGY FOR LACTATION, NE_l %%%
%---------------------------------------------------------------
% Weight gain of lamb from birth to weaning [kg]
S.WG_wean = [S.BW_weaning - S.BW_birth, 0, 0, 0];

% Net enregy req'd for lactation [MJ/head/day]
S.NE_l = 5 * S.WG_wean * S.EV_milk / 365;
%---------------------------------------------------------------


%%% NET ENERGY FOR WOOL, NE_wool %%%
%---------------------------------------------------------------
% Combine wool per head into array
S.wool_per_head = [S.wool_per_ewe, S.wool_per_ram, ...
                   S.wool_per_lamb, S.wool_per_lamb];

% Net energy req'd for wool [MJ/head/day]
S.NE_wool = S.EV_wool *  S.wool_per_head / 365;
%---------------------------------------------------------------



%%% NET ENERGY FOR PREGNANCY, NE_p %%%
%---------------------------------------------------------------
% Combine in array; to be used in subsequent calcs
S.Cp_pregnancy = [S.Cp_single, S.Cp_double, S.Cp_triple];

% Weighted pregnancy coefficient
S.Cp = sum (S.P_birth .* S.Cp_pregnancy);

% Net energy for pregnancy [MJ/head/day]
S.NE_p = [S.NE_m(1) * S.Cp, 0, 0, 0];

% Account for proportion of adult ewes which are pregnant
S.NE_p = S.NE_p * S.P_gestation;
%---------------------------------------------------------------


%%% NET ENERGY RATIOS, REM and REG %%%
%---------------------------------------------------------------
% Diet-weighted digestible energy as percent of gross energy, DE
S.DE = S.P_forage * S.DE_forage + (1 - S.P_forage) * S.DE_grain;

% Ratio of net energy available in diet for maintainence, REM
S.REM = 1.12 - 0.004092*(S.DE*100) + 0.00001126*(S.DE*100).^2 - 25.4./(S.DE*100);

% Ratio of net energy available in diet for growth, REG
S.REG = 1.164 - 0.00516*(S.DE*100) + 0.00001308*(S.DE*100).^2 - 37.4./(S.DE*100);
%---------------------------------------------------------------


%%% GROSS ENERGY, GE [MJ/head/day] %%%
%---------------------------------------------------------------
S.Term1 = (S.NE_m + S.NE_a + S.NE_l + S.NE_p) ./ S.REM; 
S.Term2 = (S.NE_g + S.NE_wool) ./ S.REG;

%Gross energy, GE [MJ/head/day]
S.GE = (S.Term1 + S.Term2) ./ S.DE;
%---------------------------------------------------------------


%%% ENTERIC FERMENTATION, EF [kg CH4/head/year] %%%
%---------------------------------------------------------------
% Combine in array
S.Ym = [S.Ym_adult, S.Ym_adult, S.Ym_lamb, S.Ym_lamb];

% Enteric fermentation, EF [kg CH4/head/year]
S.EntFerm = S.GE .* S.Ym * 365 / 55.65;

%---------------------------------------------------------------

