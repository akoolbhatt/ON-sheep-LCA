% © Akul Bhatt, 2021
%% %%% CALCULATE FEED TYPE AMOUNTS %%%
%---------------------------------------------------------------
% Forage amounts [kg/head/day]
S.forage_adult_ewe = S.DMI_forage(1) * S.forage_type; % By adult ewe
S.forage_adult_ram = S.DMI_forage(2) * S.forage_type; % By adult ram
S.forage_lamb_ewe = S.DMI_forage(3) * S.forage_type; % By lamb ewe
S.forage_lamb_ram = S.DMI_forage(4) * S.forage_type; % By lamb ram

% Grain feed amounts [kg/head/day]
S.grain_adult_ewe = S.DMI_grain(1) * S.grain_type; % By adult ewe
S.grain_adult_ram = S.DMI_grain(2) * S.grain_type; % By adult ram
S.grain_lamb_ewe = S.DMI_grain(3) * S.grain_type; % By lamb ewe
S.grain_lamb_ram = S.DMI_grain(4) * S.grain_type; % By lamb ram

% Combine forage and grain feed arrays [kg/head/day]
S.feed_adult_ewe = [S.forage_adult_ewe, S.grain_adult_ewe];
S.feed_adult_ram = [S.forage_adult_ram, S.grain_adult_ram];
S.feed_lamb_ewe = [S.forage_lamb_ewe, S.grain_lamb_ewe];
S.feed_lamb_ram = [S.forage_lamb_ram, S.grain_lamb_ram];

% Total daily feed intake per head [kg/head/day]
% Array form: [adult ewe, adult ram, lamb ewe, lamb ram]
S.feed_per_head = [sum(S.feed_adult_ewe), sum(S.feed_adult_ram),...
                   sum(S.feed_lamb_ewe), sum(S.feed_lamb_ram)];

% Total feed consumption by animals [kg/day]
S.feed_adult_ewe_total = S.feed_adult_ewe * S.sheep_pop(1); % By all adult ewes
S.feed_adult_ram_total = S.feed_adult_ram * S.sheep_pop(2);% By all adult rams
S.feed_lamb_ewe_total = S.feed_lamb_ewe * S.sheep_pop(3); % By all lamb ewes
S.feed_lamb_ram_total = S.feed_lamb_ram * S.sheep_pop(4); % By all lambs rams

% Total feed consumption on farm [kg/day]
S.feed_total = S.feed_adult_ewe_total + S.feed_adult_ram_total + ...
             S.feed_lamb_ewe_total + S.feed_lamb_ram_total;

         
%% %%% FEED LCA IMPACTS %%%

% Determine impacts array size for feed
n_feed = length(S.forage_type) + length(S.grain_type);

%---------------------------------------------------------------
%%% FEED GLOBAL WARMING (GW) IMPACTS [kg CO2-eq/head/day] %%%
%---------------------------------------------------------------
% Initialize impact arrays
GW_feed_adult_ewe = zeros(1,n_feed); GW_feed_adult_ram = zeros(1,n_feed);
GW_feed_lamb_ewe = zeros(1,n_feed); GW_feed_lamb_ram = zeros(1,n_feed);

% Row number of GW impact category in proccess_mat array
k = 2;

% Multiply kg feed element by impact/kg feed elements
for i = 1:n_feed
    GW_feed_adult_ewe(i) = S.feed_adult_ewe(i) * process_mat(k,i);
    GW_feed_adult_ram(i) = S.feed_adult_ram(i) * process_mat(k,i);
    GW_feed_lamb_ewe(i) = S.feed_lamb_ewe(i) * process_mat(k,i);
    GW_feed_lamb_ram(i) = S.feed_lamb_ram(i) * process_mat(k,i);
end
%---------------------------------------------------------------


%%% FEED AQ. EUTROPHICATION (ET) IMPACTS [kg N-eq/head/day] %%%
%---------------------------------------------------------------
% Initialize impact arrays
ET_feed_adult_ewe = zeros(1,n_feed); ET_feed_adult_ram = zeros(1,n_feed);
ET_feed_lamb_ewe = zeros(1,n_feed); ET_feed_lamb_ram = zeros(1,n_feed);

k = 5; % Row number of ET in proces_mat array

% Multiply kg feed element by impact/kg feed elements
for i = 1:n_feed
    ET_feed_adult_ewe(i) = S.feed_adult_ewe(i) * process_mat(k,i);
    ET_feed_adult_ram(i) = S.feed_adult_ram(i) * process_mat(k,i);
    ET_feed_lamb_ewe(i) = S.feed_lamb_ewe(i) * process_mat(k,i);
    ET_feed_lamb_ram(i) = S.feed_lamb_ram(i) * process_mat(k,i);
end
%---------------------------------------------------------------


%%% ENERGY DEMAND (ED) IMPACTS [MJ/head/day] %%%
%---------------------------------------------------------------
% Initialize impact arrays
CED_feed_adult_ewe = zeros(1,n_feed); CED_feed_adult_ram = zeros(1,n_feed);
CED_feed_lamb_ewe = zeros(1,n_feed); CED_feed_lamb_ram = zeros(1,n_feed);

k = 17; % Row number of CED in proces_mat array

% Multiply kg feed element by impact/kg feed elements
for i = 1:n_feed
    CED_feed_adult_ewe(i) = S.feed_adult_ewe(i) * process_mat(k,i);
    CED_feed_adult_ram(i) = S.feed_adult_ram(i) * process_mat(k,i);
    CED_feed_lamb_ewe(i) = S.feed_lamb_ewe(i) * process_mat(k,i);
    CED_feed_lamb_ram(i) = S.feed_lamb_ram(i) * process_mat(k,i);
end
%---------------------------------------------------------------


%%% FEED WATER SCARCITY (WS) IMPACTS [m^3/head/day] %%%
%---------------------------------------------------------------
% Initialize impact arrays
WS_feed_adult_ewe = zeros(1,n_feed); WS_feed_adult_ram = zeros(1,n_feed);
WS_feed_lamb_ewe = zeros(1,n_feed); WS_feed_lamb_ram = zeros(1,n_feed);

k = 18; % Row number of WS in proces_mat array

% Multiply kg feed element by impact/kg feed elements
for i = 1:n_feed
    WS_feed_adult_ewe(i) = S.feed_adult_ewe(i) * process_mat(k,i);
    WS_feed_adult_ram(i) = S.feed_adult_ram(i) * process_mat(k,i);
    WS_feed_lamb_ewe(i) = S.feed_lamb_ewe(i) * process_mat(k,i);
    WS_feed_lamb_ram(i) = S.feed_lamb_ram(i) * process_mat(k,i);
end
%---------------------------------------------------------------


%%% FEED WATER DEPLETION (WD) IMPACTS [m^3/head/day] %%%
%---------------------------------------------------------------
% Initialize impact arrays
WD_feed_adult_ewe = zeros(1,n_feed); WD_feed_adult_ram = zeros(1,n_feed);
WD_feed_lamb_ewe = zeros(1,n_feed); WD_feed_lamb_ram = zeros(1,n_feed);

k = 19; % Row number of WD in proces_mat array

% Multiply kg feed element by impact/kg feed elements
for i = 1:n_feed
    WD_feed_adult_ewe(i) = S.feed_adult_ewe(i) * process_mat(k,i);
    WD_feed_adult_ram(i) = S.feed_adult_ram(i) * process_mat(k,i);
    WD_feed_lamb_ewe(i) = S.feed_lamb_ewe(i) * process_mat(k,i);
    WD_feed_lamb_ram(i) = S.feed_lamb_ram(i) * process_mat(k,i);
end
%---------------------------------------------------------------


%% %%% ANNUAL TOTAL FEED IMPACTS PER HEAD [/head/year] %%%
%---------------------------------------------------------------
% Impact categories in arrays: [GW; ET; ED; WS; WD]

% Adult ewe
impacts_feed_adult_ewe = 365*[sum(GW_feed_adult_ewe); sum(ET_feed_adult_ewe);...
   sum(CED_feed_adult_ewe); sum(WS_feed_adult_ewe); sum(WD_feed_adult_ewe)];

% Adult ram
impacts_feed_adult_ram = 365*[sum(GW_feed_adult_ram); sum(ET_feed_adult_ram);...
   sum(CED_feed_adult_ram); sum(WS_feed_adult_ram); sum(WD_feed_adult_ram)];

% Lamb ewe
impacts_feed_lamb_ewe = 365*[sum(GW_feed_lamb_ewe); sum(ET_feed_lamb_ewe);...
   sum(CED_feed_lamb_ewe); sum(WS_feed_lamb_ewe); sum(WD_feed_lamb_ewe)];

% Lamb ram
impacts_feed_lamb_ram = 365*[sum(GW_feed_lamb_ram); sum(ET_feed_lamb_ram);...
   sum(CED_feed_lamb_ram); sum(WS_feed_lamb_ram); sum(WD_feed_lamb_ram)];



%% %%% ANNUAL TOTAL FEED IMPACTS ON FARM [/year] %%%
%---------------------------------------------------------------
% Impact categories in arrays: [GW; ET; ED; WS; WD]

% From adult ewes
impacts_feed_adult_ewe_total = impacts_feed_adult_ewe * S.sheep_pop(1);

% From Adult rams
impacts_feed_adult_ram_total = impacts_feed_adult_ram * S.sheep_pop(2);

% From Lamb ewes
impacts_feed_lamb_ewe_total = impacts_feed_lamb_ewe * S.sheep_pop(3);

% From Lamb rams
impacts_feed_lamb_ram_total = impacts_feed_lamb_ram * S.sheep_pop(4);

% Total impacts from feed on farm
impacts_feed_total = impacts_feed_adult_ewe_total + ...
                     impacts_feed_adult_ram_total + ...
                     impacts_feed_lamb_ewe_total + ...
                     impacts_feed_lamb_ram_total;


                 
                 
%% %%% ANNUAL IMPACTS BY FEED TYPE [/year] %%%
%---------------------------------------------------------------
% Array format: [GW; ET; ED; WS; WD]
%   feed type 1 [GW1; ET1; ED1; WS1; WD1]
%   feed type 2 [GW2; ET2; ED2; WS2; WD2]
%   ......................................
%   feed type n [GWn; ETn; EDn; WSn; WDn]

% Row numbers of impact categories
k = [2,5,17,18,19];

% Initialize array
impacts_feed_total_type = zeros(n_feed, length(k));

for i = 1:n_feed  
    
    for j = 1:length(k)

        impacts_feed_total_type(i,j) = 365 * S.feed_total(i) * process_mat(k(j),i);
        
    end
end









