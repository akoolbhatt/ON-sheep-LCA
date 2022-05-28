%% SHEEP LCA MODEL
% © Akul Bhatt, 2021
%
% LCA model for sheep production, accepts input arguments from struct 'S'
% For more details, see: https://github.com/akoolbhatt/ON-sheep-LCA
%
% This script does the following:
%   1. Combines related variables into arrays
%   2. Displays error, aborts calculations if invalid inputs are detected
%   3. Estimates forage amount through iterative energy balance
%   4. Runs subsequent scripts in 'Modules' to determine cradle-to-gate
%      life cycle impacts
%
%
%% POPULATION / PRODUCT MODELING INTERMEDIARY VARIABLES:

% Total number of adult rams on farm(s)
S.rams = S.ewes / S.ewes_per_ram;

% Total number of lambs on farm(s)
S.lambs = S.ewes * S.lambs_per_ewe; % Total number of lambs on farm(s)

% Sheep population array in format [adult ewe, adult ram, lamb ewe, lamb ram]
S.sheep_pop = [S.ewes; S.rams; S.lambs * (1 - S.P_male_lambs);...
               S.lambs * S.P_male_lambs];

% Average meat amount in LW per head
S.LW_per_ewe = S.BW_ewe * S.BW_LW_ewe; % per slaughtered ewe [kg LW/ewe] 
S.LW_per_ram = S.BW_ram * S.BW_LW_ram; % per slaughtered ram [kg LW/ram] 
% per slaughtered lamb [kg LW/lamb]:  
S.LW_per_lamb = mean([S.BW_lamb_ewe, S.BW_lamb_ram]) * S.BW_LW_lamb; 
  
% *Annual product output:*
% Number of animals slaughtered for meat annually:
S.ewe_slaughter = S.ewes * S.ewe_cull; % Ewes
S.ram_slaughter = S.rams * S.ram_cull; % Rams
S.lamb_slaughter = S.lambs * (1 - S.lamb_mortality); % Lambs

% ANNUAL MEAT OUTPUT [kg LW/year]:
S.ewe_meat = S.ewe_slaughter * S.LW_per_ewe; % From ewes
S.ram_meat = S.ram_slaughter * S.LW_per_ram; % From rams
S.lamb_meat = S.lamb_slaughter * S.LW_per_lamb; % From lambs
S.meat_total = S.ewe_meat + S.ram_meat + S.lamb_meat; % Total meat output on farm(s)

% ANNUAL WOOL OUTPUT [kg wool/year]:
S.ewe_wool = S.ewes * S.wool_per_ewe; % From ewes
S.ram_wool = S.rams * S.wool_per_ram; % From rams
S.lamb_wool = S.lambs * S.wool_per_lamb; % From lambs
S.wool_total = S.ewe_wool + S.ram_wool + S.lamb_wool; % Total wool output on farm(s)

% ANNUAL MILK OUTPUT [L milk/year]:
S.milk_total = S.ewes * S.milk_per_ewe;


%% DIET INTERMEDIARY VARIABLES: 

%Combine forage% in array for future calcs...
S.P_forage = [S.P_forage_adult_ewe, S.P_forage_adult_ram,...
              S.P_forage_lamb_ewe, S.P_forage_lamb_ram];

%Proportion of grains in diet
S.P_grain = 1 - S.P_forage;

%Combine forage type into array...
S.forage_type = [S.forage_corn_silage, S.forage_hay,...
                 S.forage_tillable_pasture, S.forage_rough_pasture];

             
% Combine inputted grain dry matter intake [kg/head/day] into array
% Array format: [adult ewes, adult lambs, lamb ewes, lamb rams]
S.DMI_grain = [S.grain_amount_ewe, S.grain_amount_ram,...
               S.grain_amount_lamb, S.grain_amount_lamb];

%Combine grain type % in array for future calcs...
S.grain_type = [S.grain_corn, S.grain_barley, S.grain_oat,...
                S.grain_wheat, S.grain_soybean];        

% Combine N content into array
S.N_feed = [S.N_silage, S.N_hay, S.N_till_pasture, S.N_rough_pasture,...
          S.N_corn, S.N_barley, S.N_oat, S.N_wheat, S.N_soybean];
%---------------------------------------------------------------


%% ENTERIC FERMENTATION INTERMEDIARY VARIABLES:
 
% Combine animal activity in array; to be used in subsequent calcs
S.P_activity = [S.P_housed_ewe, S.P_flat, S.P_hilly, S.P_fatten];


% Combine in array; to be used in subsequent calcs
S.P_birth = [S.P_single, S.P_double, S.P_triple];

%% MANURE MANAGEMENT INTERMEDIARY VARIABLES:

% Combine into array
S.MS = [S.MS_liquid, S.MS_solid, S.MS_drylot, S.MS_PRP];


%% *FARM OPERATIONS INTERMEDIARY VARIABLES

% Total farm area [m^2]
S.farm_size_rough = S.area_out_rough * sum(S.sheep_pop);
S.farm_size_imprvd = S.area_out_imprvd * sum(S.sheep_pop);
S.farm_size_arable = S.area_out_arable * sum(S.sheep_pop);
S.farm_size_in = S.area_in * sum(S.sheep_pop);


% Fertilizer application per year [kg/year]
S.fertilizer_in = S.fert_per_area * (S.farm_size_arable/10000);

% Combine fertilizer type into array
S.fertilizer_type = [S.fert_P, S.fert_K, S.fert_N, S.fert_lime];

% Total annual water consumption on farm [L/year]
S.water_total = 365 * (S.water_sheep * (S.ewes + S.rams) + ...
                       S.water_lamb * S.lambs + S.water_misc);


% Arable area over which tilling/rolling is performed [m^2]
S.area_tilling = S.farm_size_arable;

% Total annual bedding straw usage on farm [kg/year]...
S.bedding_total = 365 * (S.bedding_in_adult * (S.ewes + S.rams) + ...
                  S.bedding_in_lamb * S.lambs);


%% FARM OPERATIONS - TRANSPORTATION INTERMEDIARY VARS

% Array of percent of livestock transported
% Array format: [adult ewes, adult lambs, lamb ewes, lamb rams]
S.p_transport_ls = [S.p_ewe_transport, S.p_ram_transport, S.p_lamb_transport,...
                    S.p_lamb_transport];

% Array of number of sheep transported per year [#/year]
S.transport_ls = S.p_transport_ls(:) .* S.sheep_pop(:);

% Array of average body weight (mass) of sheep [kg]
S.mass_ls = [S.BW_ewe, S.BW_ram, S.BW_lamb_ewe, S.BW_lamb_ram];

% Array of total livstock transport mass [kg/year]
S.mass_transport_ls = S.transport_ls(:) .* S.mass_ls(:);

% Mass.distance of livestock transportation [kg.km/year]
S.mass_dist_ls = sum(S.mass_transport_ls) * S.dist_livestock;


% Mass of grain transported annually [kg/year]
S.mass_transport_grain = S.P_transport_grain * S.DMI_grain * S.sheep_pop * 365;

% Mass.distance of grain transportation [kg.km/year]
S.mass_dist_grain = S.mass_transport_grain * S.dist_grain;


% Mass of fertilizer transported annually [kg/year]
S.mass_transport_fert = S.P_transport_fert * S.fertilizer_in;

% Mass.distance of fertilizer transportation [kg.km/year]
S.mass_dist_fert = S.mass_transport_fert * S.dist_fert;


% Mass.distance of other goods [kg.km/year]
S.mass_dist_other = S.mass_transport_other * S.dist_other;


%%% TOTAL TRANSPORTATION MASS.DISTANCE [kg.km/year] %%%
%---------------------------------------------------------------
S.mass_dist_total = S.mass_dist_ls + S.mass_dist_grain + ...
                    S.mass_dist_fert + S.mass_dist_other;


                
%% DISPLAY ERROR FOR INCORRECT INPUT PROPORTIONS...
%---------------------------------------------------------------

% Display error if forage type values don't add up to 100
if sum(S.forage_type) ~= 1
    error("<strong>CAUTION:</strong> Forage proportions don't add up to 100%%")
end
     

% Display error if grain% values don't add up to 100
if sum(S.grain_type) ~= 1
    error("<strong>CAUTION:</strong> Grain proportions don't add up to 100%%")
end


% Display error if activity% values don't add up to 100
if sum(S.P_activity) ~= 1
    error("<strong>CAUTION:</strong> Grazing practices'" + ...
            " proportions don't add up to 100%%")
end


% Display error birth% values don't add up to 100
if sum(S.P_birth) ~= 1
    error("<strong>CAUTION:</strong> Pregnancy proportions don't add up to 100%%")
end


% Display error if manure management% values don't add up to 100
if sum(S.MS) ~= 1
    error("<strong>CAUTION:</strong> Manure management doesn't add up to 100%%")
end


% Display error if fertilizer type% values don't add up to 100
if sum(S.fertilizer_type) ~= 1
    error("<strong>CAUTION:</strong> Fertilizer proportions don't add up to 100%%")
end

% Display error if enterprise is not defined
if exist('enterprise', 'var') ~= 1
    error("<strong>CAUTION:</strong> Enterprise value must be 1, 2, or 3")
end


% Display error if enterprise =/= 1, 2, or 3
if ~ismember(enterprise, [1 2 3])
    error("<strong>CAUTION:</strong> Enterprise value must be 1, 2, or 3")
end


%---------------------------------------------------------------


 
%% *RUN SCRIPTS:*

%%% MATCH INPUTTED FORAGE TO ESTIMATED FORAGE %%%
%---------------------------------------------------------------
% Run Enteric Fermentation script in 'Modules' folder:
% for initial estimation of gross energy (GE):
enteric_ferm

% Run Forage Amount Estimation script in 'Modules' folder
% for initial estimation of forage daily matter intake (DMI):
forage_amount

% Write initial user-inputted P_forage values to a new variable
S.P_forage_initial = S.P_forage;

% Estimated forage percentage of total diet:
S.P_forage_estimate = S.DMI_forage ./ (S.DMI_forage + S.DMI_grain);

% Number of columns in DMI array, to be used in for loop below
n = length(S.DMI_forage); 

% Initiliaze variable to track how many iterations take place in while loop
iter = 0;

% For each cell in DMI columns...
for i = 1:n
    
    % Run loop as long as estimated P_forage does not equal inputted P_forage
    while round(S.P_forage_estimate(i),3) ~= round(S.P_forage(i),3)
        
        S.P_forage(i) = S.P_forage_estimate(i); % Assign estimated value to input
        enteric_ferm % Run Ent.Ferm script to re-estimate GE
        forage_amount % Run forage amount script to re-estimate P_forage
        
        % Estimated forage percentage of total diet:
        S.P_forage_estimate(i) = S.DMI_forage(i) / (S.DMI_forage(i) + S.DMI_grain(i));
        
        iter = iter + 1; % Loop iteration counter
    end
end

clear n
%---------------------------------------------------------------



%%% RUN REMAINING MODULES' SCRIPTS %%%
%---------------------------------------------------------------
% The loop above already runs the Ent.Ferm and forage estimation modules

% Run Feed LCA script in 'Modules' folder
% Outputs both feed amounts and LCIA arrays
LCA_feed

% Run Manure Management script in 'Modules' folder:
manure_mgmt

% Run Fertilizer LCA script in 'Modules' folder
LCA_fertilizer

% % Run Farm Operations LCA script in 'Modules' folder
LCA_farm_operations

% Run total LCA Impacts (per functional unit) script
LCA_total_FU

%---------------------------------------------------------------



