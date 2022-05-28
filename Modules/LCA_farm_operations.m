% © Akul Bhatt, 2021
%%% ANNUAL OPERATIONAL INPUTS %%%
%---------------------------------------------------------------
% Array of misc. operational input variables arranged in this format:
% [Shed (m^2/y), water (L/y), Elec (kWh/y), natural gas (m^3/y), diesel (MJ/y),...
%  tilling (m^2/y), straw (kg/y), LDPE (kg/y), transport(kg.km/year)]

misc_operations_in = [S.farm_size_in/S.shed_lifespan,...
                      S.water_total,...
                      S.electricity_in * sum(S.sheep_pop),...
                      0.001* S.heating_fuel_in * 365,...
                      S.diesel_in * (S.farm_size_arable/10000) * S.diesel_HV,...
                      S.area_tilling,...
                      S.bedding_total,...
                      S.plastic_in * sum(S.sheep_pop),...
                      S.mass_dist_total];

%---------------------------------------------------------------


%%% OPERATIONS IMPACTS CALULATIONS %%%
%---------------------------------------------------------------
% Define starting and ending process columns in process_mat for operations:
n_oper_start = n_feed + (n_fert + 1) + 1; % starting column#
n_oper_end = length(misc_operations_in) + (n_oper_start - 1); % Ending column#

    
% Global Warming (GW) Impacts [kg CO2-eq/year]
k = 2; % Row number of GW impact category in proccess_mat array
GW_operations = ( misc_operations_in .* process_mat(k,n_oper_start:n_oper_end) )';

% Aq. Eutrophication (ET) Impacts [kg N-eq/year]
k = 5; % Row number of ET impact category in proccess_mat array
ET_operations = ( misc_operations_in .* process_mat(k,n_oper_start:n_oper_end) )';

% Cumulative Energy Demand (ED) Impacts [MJ/year]
k = 17; % Row number of ED impact category in proccess_mat array
CED_operations = ( misc_operations_in .* process_mat(k,n_oper_start:n_oper_end) )';

% Water Scarcity (WS) Impacts [m^3/year]
k = 18; % Row number of WS impact category in proccess_mat array
WS_operations = ( misc_operations_in .* process_mat(k,n_oper_start:n_oper_end) )';

% Water Depletion (WD) Impacts [m^3/year]
k = 19; % Row number of WD impact category in proccess_mat array
WD_operations = ( misc_operations_in .* process_mat(k,n_oper_start:n_oper_end) )';

%---------------------------------------------------------------

% Attach sum of fertilizer impacts to last element of farm operations array:
GW_operations = [GW_operations; sum(GW_fertilizer)];
ET_operations = [ET_operations; sum(ET_fertilizer)];
CED_operations = [CED_operations; sum(CED_fertilizer)];
WS_operations = [WS_operations; sum(WS_fertilizer)];
WD_operations = [WD_operations; sum(WD_fertilizer)];
