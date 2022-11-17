%% Methane and N2O conversion to CO2-eq (IPCC 100y factor)
CH4_CO2 = 25; % kg CO2-eq/kg CH4
NO2_CO2 = 298; % kg CO2-eq/kg N2O

%% ALLOCATION FACTOR (USING PROTEIN MASS ALLOCATION)

% Annual protein output of products [kg protein / year]
A_protein_LW = S.protein_LW * S.meat_total; % Protein from meat
A_protein_wool = S.protein_wool * S.wool_total; % Protein from meat
A_protein = A_protein_LW + A_protein_wool; % Total protein output

% Allocation factors for meat and wool
S.meat_alloc = A_protein_LW / A_protein; % Meat
S.wool_alloc = A_protein_wool / A_protein; % Wool

% Allocation factor for milk; using NE ratio as described in FAO (2016,
% page 61) example...
S.milk_alloc = S.NE_l(1) / ( S.NE_l(1) + S.NE_g(3) );

% Multiplier (FU*allocation) to be used depending on enterprise
%---------------------------------------------------------------
if enterprise == 1 % If meat is the primary enterprise...
    mult = S.meat_alloc / S.meat_total; % [/kg LW]
    
elseif enterprise == 2 % If wool is the primary enterprise...
    mult = S.wool_alloc / S.wool_total; % [/kg greasy wool]    

elseif enterprise == 3 % If milk is the primary enterprise...
    mult = S.milk_alloc / S.milk_total; % [/kg milk] 
    
end
%---------------------------------------------------------------

%% %%% ENTERIC FERMENTATION PER FUNCTIONAL UNIT %%%
%---------------------------------------------------------------
% Convert Enteric fermentation values from CH4 to CO2 [kg CO2-eq/head/year]
EntFerm_CO2 = S.EntFerm * CH4_CO2;

% GW impacts of enteric fermentation per functional unit [kg CO2-eq/product]
GW_EF_FU = EntFerm_CO2 * S.sheep_pop * mult;

%---------------------------------------------------------------


%% %%% MANURE IMPACTS PER FUNCTIONAL UNIT %%%
%---------------------------------------------------------------
%Convert manure impacts from CH4/NO2 to CO2 [kg CO2-eq/head/year]
manure_CH4_CO2 = S.manure_CH4 * CH4_CO2; % Direct methane emisisons
manure_direct_CO2 = S.manure_direct_N2O * NO2_CO2; % Direct N2O emissions
manure_CO2_vol = S.manure_N2O_vol * NO2_CO2; % Indirect N2O from volatization
manure_CO2_leach = S.manure_N2O_leach * NO2_CO2; % Indirect N2O from leaching

% GW impacts of manure per functional unit [kg CO2-eq/product]
GW_manure_CH4_CO2_FU = manure_CH4_CO2 * S.sheep_pop * mult;
GW_manure_direct_CO2_FU = manure_direct_CO2 * S.sheep_pop * mult;
GW_manure_CO2_vol_FU = manure_CO2_vol * S.sheep_pop * mult;
GW_manure_CO2_leach_FU = manure_CO2_leach * S.sheep_pop * mult;


% TOTAL GW impacts from manure CH4/NO2 [kg CO2-eq/product]
GW_manure_FU = GW_manure_CH4_CO2_FU + GW_manure_direct_CO2_FU + ...
               GW_manure_CO2_vol_FU + GW_manure_CO2_leach_FU; % Meat [kg LW]

%---------------------------------------------------------------


%% %%% FEED IMPACTS PER FUNCTIONAL UNIT %%%
%---------------------------------------------------------------

% Impact categories in impact array below are [GW; ET; CED; WS; WD]

% IMPACTS of feed from adult ewe population per FU [/product]
%-----------------------------------------------------
impacts_feed_adult_ewe_FU = impacts_feed_adult_ewe' * S.sheep_pop(1)...
                            * mult;
                        
% IMPACTS of feed from adult ram population per FU [/product]
%-----------------------------------------------------
impacts_feed_adult_ram_FU = impacts_feed_adult_ram' * S.sheep_pop(2)...
                            * mult;

% IMPACTS of feed from lamb ewe population per FU [/product]
%-----------------------------------------------------
impacts_feed_lamb_ewe_FU = impacts_feed_lamb_ewe' * S.sheep_pop(3)...
                           * mult;

% IMPACTS of feed from lamb ram population per FU [/product]
%-----------------------------------------------------
impacts_feed_lamb_ram_FU = impacts_feed_lamb_ram' * S.sheep_pop(4)...
                           * mult; 

% IMPACTS of feed from entire population per FU [/product]
%-----------------------------------------------------
impacts_feed_FU = impacts_feed_adult_ewe_FU + impacts_feed_adult_ram_FU...
         + impacts_feed_lamb_ewe_FU + impacts_feed_lamb_ram_FU; 


%---------------------------------------------------------------


%% %%% IMPACTS OF FARM OPERATIONS PER FUNCTIONAL UNIT %%%
%---------------------------------------------------------------

% Total annual operational (including fertilizer) impact array in 
% format [GW; ET; CED; WS; WD]
impacts_oper = [sum(GW_operations), sum(ET_operations), sum(CED_operations)...
                sum(WS_operations), sum(WD_operations)];

% IMPACTS of farm operations per functional unit [/product]
impacts_oper_FU = impacts_oper * mult; 

%---------------------------------------------------------------



