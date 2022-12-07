% SHEEP LCA MODEL
% RELATIVE SENSITIVITY VALUE (RSV) CALCULATIONS / EXPORT / PLOTTING
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

% Duplicate structure for subsequent calculations
S = S0;

% Paramters to be changed
name_parameters = fieldnames(S0); % Name of input parameters
n_parameters = length(fieldnames(S0)); % Number of input parameters


%---------------------------------------------------------------
%Script mode (OAT = 2)
mode = 2;

% Primary enterprise: 1 = Meat, 2 = Wool, 3 = Milk
enterprise = 1;



%% DEFINE LABELS:

% Label of impact category
impact_cat_labels = ["Global Warming (GW)", "Eutrophication (ET)", ...
    "Cumulative Energy Demand (CED)", "Water Scarcity (WS)", ...
    "Water Depletion (WD)"];

% Label of phases
phase_labels = ["Enteric Emissions", "Manure Management",...
    "Feed Production", "Operations", "Total"];


% Pick appropriate FU unit based on 'enterprise'
%--------------------------------------------------------------------------
if enterprise == 1 % If meat is the primary enterprise...
    yaxis_FU_unit = "kg LW";
    
elseif enterprise == 2 % If wool is the primary enterprise...
    yaxis_FU_unit = "kg wool";    

elseif enterprise == 3 % If milk is the primary enterprise...
    yaxis_FU_unit = "L milk"; 
    
end
%--------------------------------------------------------------------------

% Y-axis labels for each impact category
yaxis_labels = [strcat("GW Impacts [kg CO_2 eq / ", yaxis_FU_unit, "]"), ...
                strcat("ET Impacts [kg N eq / ", yaxis_FU_unit, "]"), ...
                strcat("CED Impacts [MJ / ", yaxis_FU_unit, "]") ,...
                strcat("WS Impacts [m^3 / ", yaxis_FU_unit, "]") ,...
                strcat("WD Impacts [m^3 / ", yaxis_FU_unit, "]")];



%% DEFINE INPUT PARAMETER ARRAY INDICES
%--------------------------------------------------------------------------

% Indices of input parameters related to population / products
population_loc = [1:14,18:21];

% Indices of input parameters related to feed
feed_loc = [30:32,39,40];

% Indices of input parameters related to manure management
manure_loc = [54,55:78];

% Indices of input parameters related to enteric ferm.
enteric_loc = [79:81,90:110];
           
% Indices of input parameters related to farm operations
operations_loc = [111:116,121:140];

% Stitch all input parameter indices together
OAT_index = [population_loc, feed_loc, manure_loc,...
             enteric_loc, operations_loc];


% Makes a vector that will hold the input parameter categories in order.
parameter_category = string(zeros(length(name_parameters),1));

% Assigns categories to rows specified in each index vector.
parameter_category(population_loc) = "Populations";
parameter_category(feed_loc) = "Feed";
parameter_category(manure_loc) = "Manure";
parameter_category(enteric_loc) = "Enteric";
parameter_category(operations_loc) = "Operations";

% Empties rows containing zeros.
parameter_category(parameter_category == "0") = "";


%% DEFINE SENSITIVITY PARAMETERS HERE:

min_p = 75 / 100; %Minimum percentage of default value
max_p = 125 / 100; %Maximum percentage of deafult value
incr = 5 / 100; % Increment by which input parameters are varied


% Number of iterations per parameter
n_incr = round( 1 + (max_p - min_p) / incr );

% Generates a vector containing all increment values (x-axis)
incr_val = linspace(min_p, max_p, n_incr);


% Number of phases [EF, manure, feed, operations]
n_phases = 4; 

% Initialize impact (per FU) 3d arrays
% Array format:
%                   /      /         /       /       / 110%     
%                  /      /         /       /       /      
%                 /      /         /       /       / ...    
%                /      /         /       /       /      
%               /      /         /       /       / 90% 
%                      /        /       /       / 
%             EF    manure    feed    oper    Total
%    param 1   .      .        .       .        .
%    param 2   .      .        .       .        .
%      ...     .      .        .       .        .
%      ...     .      .        .       .        .
%    param n   .      .        .       .        .

GW_phases_FU_OAT = zeros(n_parameters, n_phases + 1, n_incr);
ET_phases_FU_OAT = zeros(n_parameters, n_phases + 1, n_incr);
CED_phases_FU_OAT = zeros(n_parameters, n_phases + 1, n_incr);
WS_phases_FU_OAT = zeros(n_parameters, n_phases + 1, n_incr);
WD_phases_FU_OAT = zeros(n_parameters, n_phases + 1, n_incr);

% Turn default structure values into n x 1 array
S0_array = struct2array(S0)';

% Duplicate array for subsequent calcs...
S_array = S0_array;

% Value multiplication factor (VMF) for first loop... 
VMF = min_p;



%% SENSITIVTY ANALYSIS CALCULATION

for xx = 1 : n_parameters % For each input parameter...
        
    for zz = 1: n_incr % For each increment change in parameter value...
        
        % Multiply parameter value by the multiplication factor
        S_array(xx) = S0_array(xx) * VMF;
        
        % Create 2 x n vector of changed values (to recreate into structure)
        V = [vars'; num2cell(S_array)'];

        % Create structure from vector
        S = struct(V{:});
        
        % Run script with intermediary OAT calcs....
        sheep_LCA_model
        
        % Impacts per FU for each phase;
        % Note that the 'Total' column is made to be 0 for now...
        GW_phases_FU_OAT(xx,:,zz) = [GW_EF_FU, GW_manure_FU, ...
                impacts_feed_FU(1), impacts_oper_FU(1), 0];
        ET_phases_FU_OAT(xx,:,zz) = [0, 0, impacts_feed_FU(2), impacts_oper_FU(2), 0];
        CED_phases_FU_OAT(xx,:,zz) = [0, 0, impacts_feed_FU(3), impacts_oper_FU(3), 0];
        WS_phases_FU_OAT(xx,:,zz) = [0, 0, impacts_feed_FU(4), impacts_oper_FU(4), 0];
        WD_phases_FU_OAT(xx,:,zz) = [0, 0, impacts_feed_FU(5), impacts_oper_FU(5), 0];
        
        % Fill in 'Total' column to be the summation of all the phases.
        GW_phases_FU_OAT(xx,n_phases+1,zz) = sum(GW_phases_FU_OAT(xx,1:n_phases,zz));        
        ET_phases_FU_OAT(xx,n_phases+1,zz) = sum(ET_phases_FU_OAT(xx,1:n_phases,zz));
        CED_phases_FU_OAT(xx,n_phases+1,zz) = sum(CED_phases_FU_OAT(xx,1:n_phases,zz));
        WS_phases_FU_OAT(xx,n_phases+1,zz) = sum(WS_phases_FU_OAT(xx,1:n_phases,zz));
        WD_phases_FU_OAT(xx,n_phases+1,zz) = sum(WD_phases_FU_OAT(xx,1:n_phases,zz));
        
        % Value multiplication factor increased by defined increment for next loop...
        VMF = VMF + incr;
        
    end
    
    % Reset all changed values to default for the next parameter iteration
    S_array = S0_array;
    
    % Reset multiplicative factor for the next parameter iteration
    VMF = min_p;
    
end



%% RELATIVE SENSITIVITY VALUES (RSV) CALCULATIONS

%Copies impact results for use in RSV calculations

% Initiliaze RSV arrays
rsv = zeros(n_parameters,n_phases + 1);
GW_rsv = zeros(n_parameters,n_phases + 1);
ET_rsv = zeros(n_parameters,n_phases + 1);
CED_rsv = zeros(n_parameters,n_phases + 1);
WS_rsv = zeros(n_parameters,n_phases + 1);
WD_rsv = zeros(n_parameters,n_phases + 1);

% Element number of baseline results in z-axis of 3d array
k = find(incr_val == 1);

% Calculates RSV values for all parameters of all impacts categories
for n_rsv = 1 : length(impact_cat_labels) % For all impact categories...
    
    %Selects the appropriate impact for each iteration
    if n_rsv == 1   
        impact = GW_phases_FU_OAT;
        
    elseif n_rsv == 2
        impact = ET_phases_FU_OAT;
            
    elseif n_rsv == 3
        impact = CED_phases_FU_OAT;
            
    elseif n_rsv == 4
        impact = WS_phases_FU_OAT;
            
    elseif n_rsv == 5
        impact = WD_phases_FU_OAT;
            
    end
    
    % Calculates all RSV values for parameters impacting GW
    % Loops through all parameters
    for i = 1:n_parameters
        % Loops through all phases
        for j = 1:n_phases + 1
            % Calculates the RSV as the slope between extremes of sensitivity
            rsv(i,j) = ((impact(i,j,1)-impact(i,j,n_incr))/(impact(i,j,k)))...
                /(incr_val(1)-incr_val(n_incr));
   
        end
    end 

    % Assigns the RSV values to the appropriate impact
    if n_rsv == 1   
        GW_rsv = rsv;
        
    elseif n_rsv == 2
        ET_rsv = rsv;
            
    elseif n_rsv == 3
        CED_rsv = rsv;
            
    elseif n_rsv == 4
        WS_rsv = rsv;
            
    elseif n_rsv == 5
        WD_rsv = rsv;
    
    end

end


%% EXPORT RSVs to spreadsheet

% Output worksheet name
out_ws_name = 'MATLAB_RSV_Output';

% Export parameter names/categories
xlswrite(spreadsheet_name, name_parameters, out_ws_name, 'A3')
xlswrite(spreadsheet_name, parameter_category, out_ws_name, 'B3')

% Export RSVs
xlswrite(spreadsheet_name, GW_rsv, out_ws_name, 'C3')
xlswrite(spreadsheet_name, CED_rsv, out_ws_name, 'H3')
xlswrite(spreadsheet_name, WD_rsv, out_ws_name, 'M3')



%% PLOT SENSITIVITY

%%% Define input parameter category label (for graph)
%--------------------------------------------------------------------------
%%% IMPORTANT:
%%% Pick the parameter category to plot (using 'input_category')
%%%%% Population/productivity -----> 'population_loc'
%%%%% Feed production -------------> 'feed_loc'
%%%%% Enteric emissions------------> 'feed_loc'
%%%%% Manure emissions ------------> 'manure_loc'
%%%%% Farm operations -------------> 'operations_loc'

% Define input category based on index array
input_category = population_loc;

% Record first element value of index array
a = input_category(1);

% Match value of 'a' to first element value of index arrays to determine
% which input category is targeted...
if a == population_loc(1)
    input_category_label = "Population/Production Inputs";
    
elseif a == feed_loc(1)
    input_category_label = "Feed Inputs";
    
elseif a == manure_loc(1)
    input_category_label = "Manure Management Inputs";
    
elseif a == enteric_loc(1)
    input_category_label = "Enteric Fermentation Inputs";
    
elseif a == operations_loc(1)
    input_category_label = "Operations Inputs";
    
else
    input_category_label = "Error";
    
end
%--------------------------------------------------------------------------

%%% Specify varying line types help differentiate variables
%--------------------------------------------------------------------------

marker = {'-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.',...
    '-','--',':','-.','-','--',':','-.','-','--',':','-.'};

%--------------------------------------------------------------------------


%%% CREATE SENSITIVITY ANALYSIS FIGURES:
%--------------------------------------------------------------------------

% Create a new figure for each impact category...
for n_fig = 1 : length(impact_cat_labels) 

for yplot = 1 : n_phases + 1 % For each phase (+ 'total' column)...
    
    figure(n_fig + 1); % Create figure window for each impact category
    
    % Specify size of subplot that will hold output figures and defines 
    % the location of each figure within the subplot for each iteration
    subplot(2, floor(n_phases/2) + 1, yplot)   
    
    % Assign appropriate title to each figure
    title(phase_labels(yplot));
   
    % Retain current plot window for subsequent graphs
    hold on    
    
    % For each input parameter index specified in 'input_category' array
    for xplot = input_category
        
        % Generates a 1 x n_incr vector of z values (i.e. y-axis values)
        % Extract impact values from appropriate 3d output array based on
        % impact category / figure window...
        
        if n_fig == 1   
            impact = squeeze( GW_phases_FU_OAT(xplot ,yplot ,: ) );
        
        elseif n_fig == 2
            impact = squeeze( ET_phases_FU_OAT(xplot ,yplot ,: ) );
            
        elseif n_fig == 3
            impact = squeeze( CED_phases_FU_OAT(xplot ,yplot ,: ) );
            
        elseif n_fig == 4
            impact = squeeze( WS_phases_FU_OAT(xplot ,yplot ,: ) );
            
        elseif n_fig == 5
            impact = squeeze( WD_phases_FU_OAT(xplot ,yplot ,: ) );
            
        end
            
        % Plots sensitivity of variable
        plot(incr_val, impact', 'LineStyle', marker{xplot}, 'LineWidth',1.5)
        
    end

    % Generates x-axis label
    xlabel('Increment')

    % Generates y-axis label
    ylabel(yaxis_labels(n_fig),'FontSize',12)   

    % Generate title 
    sgtitle(strcat(impact_cat_labels(n_fig)," - ",input_category_label));

    % Set off the hold state for the next impact category
    hold off

end

    % Generates legend
    legend(name_parameters(input_category),...
        'NumColumns',2,'FontSize',10,'Interpreter','none',...
        'Position',[0.75, 0.22, 0.1, 0.2]);  
    
    % Set window size
    set(gcf,'position',[0,0,1200,700])

end


