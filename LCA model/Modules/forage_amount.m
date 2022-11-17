% © Akul Bhatt, 2021
%%% ESTIMATE FORAGING FEED AMOUNTS %%%
%---------------------------------------------------------------

% Acount for grain wastage based on feeding practices
% According to FAO (2016), wastage = 5% for specialized feeding factilities
                         % wastage = 20% for feed spread on ground
if S.feeding_practice == 0
    S.feed_waste = 0.05;
else
    S.feed_waste = 0.2;
end

% Energy from inputted grain amounts [MJ/head/day]
S.E_grain = S.DMI_grain * S.DMI_energy_grain * S.DE_grain * (1 - S.feed_waste);

% Estimated energy from forage [MJ/head/day]
S.E_forage = S.GE - S.E_grain;

% Replace negative E_forage value with 0 in case all of req'd GE is
% provided by grains....
for i = 1:4
    if S.E_forage(i) < 0
        S.E_forage(i) = 0;
    end
end

% Estimated dry matter intake based on caclulated GE [kg/head/day]
S.DMI_forage = S.E_forage / S.DMI_energy_forage;
