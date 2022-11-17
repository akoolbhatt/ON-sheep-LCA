% © Akul Bhatt, 2021
%%% FERTILIZER PRODUCTION ANNUAL IMPACTS [/year] %%%
%---------------------------------------------------------------
% Determine impacts array size for fertilizer
n_fert = length(S.fertilizer_type);

% Global Warming (GW) Impacts [kg CO2-eq/year]
k = 2; % Row number of GW impact category in proccess_mat array
GW_fertilizer = ( S.fertilizer_in * ...
                S.fertilizer_type .* process_mat(k,(n_feed+1):(n_feed+n_fert)) )';

% Aq. Eutrophication (ET) Impacts [kg N-eq/year]
k = 5; % Row number of ET impact category in proccess_mat array
ET_fertilizer = ( S.fertilizer_in * ...
                S.fertilizer_type .* process_mat(k,(n_feed+1):(n_feed+n_fert)) )';

% Cumulative Energy Demand (ED) Impacts [MJ/year]
k = 17; % Row number of ED impact category in proccess_mat array
CED_fertilizer = ( S.fertilizer_in * ...
                S.fertilizer_type .* process_mat(k,(n_feed+1):(n_feed+n_fert)) )';

% Water Scarcity Impacts [m^3/year]
k = 18; % Row number of WS impact category in proccess_mat array
WS_fertilizer = ( S.fertilizer_in * ...
                S.fertilizer_type .* process_mat(k,(n_feed+1):(n_feed+n_fert)) )';

% Water Depletion Impacts [m^3/year]
k = 19; % Row number of WD impact category in proccess_mat array
WD_fertilizer = ( S.fertilizer_in * ...
                S.fertilizer_type .* process_mat(k,(n_feed+1):(n_feed+n_fert)) )';
%---------------------------------------------------------------


%%% FERTILIZER APPLICATION IMPACTS [/year] %%%
%---------------------------------------------------------------

k = [2, 5, 17, 18, 19]; % Row numbers of impact categories
l = n_feed + n_fert + 1; % Column number of fertilizer application process

fert_app_impacts = zeros(1,length(k)); % Initialize array


for i = 1:length(k)
    fert_app_impacts(i) = S.farm_size_arable * process_mat( k(i), l );
end

% Attach fertilizer application impacts to last element of fertilizer array:
GW_fertilizer = [GW_fertilizer; fert_app_impacts(1)];
ET_fertilizer = [ET_fertilizer; fert_app_impacts(2)];
CED_fertilizer = [CED_fertilizer; fert_app_impacts(3)];
WS_fertilizer = [WS_fertilizer; fert_app_impacts(4)];
WD_fertilizer = [WD_fertilizer; fert_app_impacts(5)];
%---------------------------------------------------------------

clear k l