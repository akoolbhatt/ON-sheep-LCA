% SHEEP LCA MODEL
% MONTE CARLO (MC) CALCULATIONS / EXPORT / PLOTTING
% © Akul Bhatt

clear
%% IMPORT LCI/LCIA PROCESSES

% Add paths to 'Modules' folder so MATLAB can assess scripts in those folder
addpath('LCA model'); addpath('LCA model\Modules');

%%% IMPORT LCA PROCESSES FROM SPREADSHEET %%%
%---------------------------------------------------------------
% Turn off warning for modified column headers
warning('off','all')

% Spreadsheet name 
spreadsheet_name = 'MATLAB_inputs_outputs.xlsx';

% Import table from spreadsheet to variable
process = readtable(spreadsheet_name, Sheet='impact_factors');

% Extract values from column 2 to n in table (for future calcs)
nn = width(process); % Number of columns in processs table
process_mat = table2array(process(:,2:nn)); % Array
process_mat(isnan(process_mat)) = 0; % Turn 'NaN' into 0...



%% IMPORT DEFAULT PARAMETERS TO STRUCTURE S0

% Worksheet name to be imported
worksheet_name = 'input_params';

% Import table from spreadsheet to variable
def_parameters = readtable(spreadsheet_name, 'Sheet', worksheet_name);
clear worksheet_name

% Turn on warnings again (...just in case)
warning('on','all')

% Extract cell array of variable names from table
vars = def_parameters.Variable;

% Extract paramter info and convert to cell
values_def = num2cell(def_parameters.Value); % Default values

% Create 2 x n array of variable names and values
V_def = [vars'; values_def']; % Default values

% Create structure of values and distrbution type from array
S0 = struct(V_def{:});



%% MC SETUP

% Number of variables
num_vars = length(vars);

% Number of phases (including total)
n_phases = 4 + 1; 

% Number of random samplings (MC array size)
MC_size = 10000;

% Set LCA MODEL mode and FU
enterprise = 1; % FU = meat
mode = 2; % Avoid sum errors

% MC loop progress - print criteria (e.g, print progress at every 10%...)
print_cr = 10; 



%% CREATE STRUCTURE OF VALUES AND STATISTICAL DISTRIBUTION INFO

par_dist = num2cell(def_parameters.Distribution); % Distribution type
par1 = num2cell(def_parameters.par1); % Param 1 value of dist
par2 = num2cell(def_parameters.par2); % Param 2 value of dist
par3 = num2cell(def_parameters.par3); % Param 3 value of dist

P_dist_type = [vars'; par_dist']; % Distribution type
Par1 = [vars'; par1']; % Param 1 value of dist
Par2 = [vars'; par2']; % Param 2 value of dist
Par3 = [vars'; par3']; % Param 3 value of dist

DT = struct(P_dist_type{:});
P1 = struct(Par1{:});
P2 = struct(Par2{:});
P3 = struct(Par3{:});



%% CREATE DISTRIBUTION OBJECT FOR EACH VARIABLE (& STORE IN STRUCT)

% Create empty structure (initialize)
D = [vars'; num2cell(zeros(num_vars,1))']; % Array of variable name and zeros
D = struct(D{:}); % Turn array into structure

% Make distribution object and store in struct D
for i = 1 : num_vars
    
    % Check if distribution type is associated with variable...
    % If YES, then make dist. object and store in struct D
    if isempty(DT.(vars{i})) == 0 
        
        % If only 1-parameter distribution...
        if isnan(P2.(vars{i})) &&  isnan(P3.(vars{i}))
        
            D.(vars{i}) = makedist(DT.(vars{i}),P1.(vars{i}));
        
        % If only 2-parameter distribution...    
        elseif isnan(P3.(vars{i}))
            
            D.(vars{i}) = makedist(DT.(vars{i}), P1.(vars{i}), P2.(vars{i}));
        
        % If 3-parameter distribution...    
        else
            
            D.(vars{i}) = makedist(DT.(vars{i}), P1.(vars{i}),...
                                   P2.(vars{i}), P3.(vars{i}));
                                                               
        end
    end
end




%% GENERATE ARRAY OF RANDOM PARAMETER VALUES

% Initialize array which will store randomly-sampled values
rand_array = zeros(MC_size, num_vars);

for i = 1 : num_vars % For each variable
    
    % Check if distribution type is associated with variable...
    % If YES, then randomly sample values and store in array
    if isempty(DT.(vars{i})) == 0 
        
        % Generate m x 1 random values
        rand_array(:,i) = random(D.(vars{i}), MC_size, 1);
        
        % Turn negative values into zero...
        rand_array(rand_array < 0) = 0;
        
    % If NO, store default value in array    
    else 
        
        rand_array(:,i) = S0.(vars{i});
        
    end
end


%% MONTE-CARLO - SETUP

% Initialize structure
S = S0;

% Initialize impact arrays 
GW_MC = zeros(MC_size, n_phases); % Global warming impacts
ET_MC = zeros(MC_size, n_phases); % Eutrophication impacts
CED_MC = zeros(MC_size, n_phases); % CED Impacts
WD_MC = zeros(MC_size, n_phases); % Water depletion impacts


%% RUN MONTE-CARLO OUTPUT LOOP

for idx1 = 1 : MC_size

    for idx2 = 1 : num_vars
        
        % Assign appropriate value to structure variable
        S.(vars{idx2}) = rand_array(idx1, idx2);
        
    end
    
    % Run sheep LCA model script
    sheep_LCA_model
    
    % Store impact values to array
    % Format: [Ent. Ferm, Feed, Manure, Operations]
    GW_MC(idx1,1:4) = [GW_EF_FU, impacts_feed_FU(1), GW_manure_FU, impacts_oper_FU(1)];
    ET_MC(idx1,1:4) = [0, impacts_feed_FU(2), 0, impacts_oper_FU(2)];
    CED_MC(idx1,1:4) = [0, impacts_feed_FU(3), 0, impacts_oper_FU(3)];
    WD_MC(idx1,1:4) = [0, impacts_feed_FU(5), 0, impacts_oper_FU(5)];
    
    % Print progress of MC loop
    progress = 100 * idx1 / MC_size; % Perecent progress of loop
    
    if mod(progress, print_cr) == 0 % Print progress when criteria is met
        fprintf('MC Progress: %.0f%%\n', progress)
    end
    
    % clear S % Clear structure... just in case
        
end
clear idx1 idx2


% Filter outliers automatically
for idx1 = 1 : 4 % Number of phases
    
    GW_MC(:,idx1) = filloutliers(GW_MC(:,idx1),'previous');
    ET_MC(:,idx1) = filloutliers(ET_MC(:,idx1),'previous'); 
    CED_MC(:,idx1) = filloutliers(CED_MC(:,idx1),'previous');
    WD_MC(:,idx1) = filloutliers(WD_MC(:,idx1),'previous');
    
end



%% TOTAL MONTE-CARLO IMPACTS ARRAY OF IMPACTS

% Fill in total (last) column of bseline impact arrays
for idx2 = 1 : MC_size
    
    GW_MC(idx2,5) = sum(GW_MC(idx2,1:4));
    ET_MC(idx2,5) = sum(ET_MC(idx2,1:4));
    CED_MC(idx2,5) = sum(CED_MC(idx2,1:4));
    WD_MC(idx2,5) = sum(WD_MC(idx2,1:4));
    
end
clear idx1 idx2

% Combine total impacts into single matrix
% Format: [GW, ET, CED, WD]
impacts_MC = [GW_MC(:,5), ET_MC(:,5), CED_MC(:,5), WD_MC(:,5)];


%% EXPORT LCA OUTPUT

out_ws_name = 'MATLAB_MC_Output';

writematrix(GW_MC,spreadsheet_name, 'Sheet', out_ws_name, 'Range', 'B3')
writematrix(CED_MC,spreadsheet_name, 'Sheet', out_ws_name, 'Range', 'G3')
writematrix(WD_MC,spreadsheet_name, 'Sheet', out_ws_name, 'Range', 'L3')



%% PLOT MC OUTPUT HISOGRAM

%%% HISTOGRAM + XLINE GRAPH SETUP
% Transparency (alpha)
alp = 0.15;

% Line color array
lc = [0.0000, 0.0000, 0.0000;...% Black
      0.8588, 0.5451, 0.0784;...% Orange
      0.0000, 0.4471, 0.7412];...% Blue
  
% Line thickness
lth = 2;

% Means/stdevs (for xline)
impact_mean = [mean(impacts_MC(:,1)), mean(impacts_MC(:,3)),...
                  mean(impacts_MC(:,4))];

impact_std = [std(impacts_MC(:,1)), std(impacts_MC(:,3)),...
                  std(impacts_MC(:,4))];

% Xline label
xline_lab1 =  sprintf('%.2f\n(%.2f)',impact_mean(1),impact_std(1));
xline_lab2 =  sprintf('%.2f\n(%.2f)',impact_mean(2),impact_std(2));
xline_lab3 =  sprintf('%.2f\n(%.2f)',impact_mean(3),impact_std(3));


%$% GLOBAL WARMING (GW) HISTOGRAM + XLINE
figure(1)
hold on

% Xline                        
xline(mean(impacts_MC(:,1)),'Label', xline_lab1,...
    'Color', lc(1,:), 'LineWidth', lth, 'LabelOrientation', 'horizontal',...
    'LabelHorizontalAlignment', 'center')

% Histograms
histogram(impacts_MC(:,1), 'FaceColor', lc(1,:),...
                              'FaceAlpha', alp, 'EdgeAlpha', alp)

% Axis setup
xlabel('Global Warming Impacts [kg CO_2 eq / kg LW]')
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
set(gca,'YColor','w')
set(gca,'Box','off')

hold off


%$% ENERGY DEMAND (ED) HISTOGRAM + XLINE
figure(2)
hold on

% Xline                        
xline(mean(impacts_MC(:,3)),'Label', xline_lab2,...
    'Color', lc(1,:), 'LineWidth', lth, 'LabelOrientation', 'horizontal',...
    'LabelHorizontalAlignment', 'center')

% Histograms
histogram(impacts_MC(:,3), 'FaceColor', lc(1,:),...
                              'FaceAlpha', alp, 'EdgeAlpha', alp)

% Axis setup
xlabel('Energy Demand [MJ / kg LW]')
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
set(gca,'YColor','w')
set(gca,'Box','off')

hold off


%$% WATER DEPLETION (WD) HISTOGRAM + XLINE
figure(3)
hold on

% Xline                        
xline(mean(impacts_MC(:,4)),'Label', xline_lab3,...
    'Color', lc(1,:), 'LineWidth', lth, 'LabelOrientation', 'horizontal',...
    'LabelHorizontalAlignment', 'center')

% Histograms
histogram(impacts_MC(:,4), 'FaceColor', lc(1,:),...
                              'FaceAlpha', alp, 'EdgeAlpha', alp)

% Axis setup
xlabel('Water Depletion [m^3 / kg LW]')
set(gca,'YTickLabel',[]);
set(gca,'YTick',[]);
set(gca,'YColor','w')
set(gca,'Box','off')

hold off





