clear
tic
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


%% IMPORT FARM PARAMETERS INTO TABLE

% Spreadsheet name and worksheet to be imported
worksheet_name = 'MATLAB_inputs_farmdata';

% Turn off warning for modified column headers
warning('off','all')

% Import table from spreadsheet to variable
input_parameters = readtable(spreadsheet_name, 'Sheet', worksheet_name);
clear worksheet_name

% Turn on warnings again (...just in case)
warning('on','all')

% Column number BEFORE column 'n1' in table
n_start = 3;

% Determine the last column index of table
n_col = width(input_parameters);

% Number of farm samples
n_farms = n_col - n_start;


%% IMPORT PARAMETER VALUES INTO STRUCTURE F

% Extract cell array of variable names from table
vars = input_parameters.Variable;

% Create empty struct F
V = [vars'; num2cell(zeros(1,length(vars)))];
F(1:n_farms) = struct(V{:});

% Fill in structure F with farm data
for idx = 1 : n_farms
    
    % Extract paramter info and convert to cell
    values = table2cell(input_parameters(:,idx+n_start));
    
    % Create 2 x n array of variable names and values
    V = [vars'; values'];
    
    % Fill in values in structure
    F(idx) = struct(V{:});
        
end
clear idx


% Replace blank (NaN) values with default values
for idx1 = 1 : length(F) % For each structure element...
    
    for idx2 = 1 : length(vars) % For each parameter...
        
        % If field value is blank
        if isnan(F(idx1).(vars{idx2}))
            
            % Replace with default value
            F(idx1).(vars{idx2}) = S0.(vars{idx2});
        
        end
    end
end
clear idx1 idx2
    

%% LCA RESULTS SETUP

% Number of phases (including total)
n_phases = 4 + 1;

% Set LCA MODEL mode and FU
enterprise = 1; % FU = meat
mode = 2; % Avoid sum errors

% Initialize impact array arrays
GW_FU_farms = zeros(n_farms, n_phases); %Global warming impacts
ED_FU_farms = zeros(n_farms, n_phases); %Energy demand impacts
WD_FU_farms = zeros(n_farms, n_phases); %Water depletion impacts

% Initialize feed relative impact array
% Format: [feed type 1, feed type 2, ..., feed type n]
n_feed = 9; % Number of feed types
GW_feed_farms = zeros(n_farms, n_feed); % Global warming
ED_feed_farms = zeros(n_farms, n_feed); % Energy demand
WD_feed_farms = zeros(n_farms, n_feed); % Water depletion

% Initializae manure relative GW impacts
% Format: [manure CH4, direct N2O, vol N2O, leach N2O]
GW_manure_farms = zeros(n_farms,4);

% Initialize operations relative impact array
% Format: [Shed, water, ..., fertilization]
GW_oper_farms = zeros(n_farms, 10);
ED_oper_farms = zeros(n_farms, 10);
WD_oper_farms = zeros(n_farms, 10);


%% Run LCA model and extract results
for idx = 1 : n_farms

    % Assign values to structure S
    S = F(idx);
    
    % Run model
    sheep_LCA_model
    
    % Extract results:
    
    GW_FU_farms(idx,1:4) = [GW_EF_FU, impacts_feed_FU(1),...
        GW_manure_FU, impacts_oper_FU(1)];
    GW_FU_farms(idx,5) = sum(GW_FU_farms(idx,1:4));
    
    ED_FU_farms(idx,1:4) = [0, impacts_feed_FU(3),...
        0, impacts_oper_FU(3)];
    ED_FU_farms(idx,5) = sum(ED_FU_farms(idx,1:4));
    
    WD_FU_farms(idx,1:4) = [0, impacts_feed_FU(5),...
        0, impacts_oper_FU(5)];
    WD_FU_farms(idx,5) = sum(WD_FU_farms(idx,1:4));
    
    GW_feed_farms(idx,:) = impacts_feed_total_type(:,1)';
    ED_feed_farms(idx,:) = impacts_feed_total_type(:,3)';
    WD_feed_farms(idx,:) = impacts_feed_total_type(:,5)';
    
    GW_manure_farms(idx,:) = [GW_manure_CH4_CO2_FU, GW_manure_direct_CO2_FU, ...
        GW_manure_CO2_vol_FU, GW_manure_CO2_leach_FU];
    
    GW_oper_farms(idx,:) = GW_operations';
    ED_oper_farms(idx,:) = CED_operations';
    WD_oper_farms(idx,:) = WD_operations';
    
    % Print progress
    fprintf('Farm no.%d completed\n', idx)
    
    % Store final 'S' into structure 'G'
    G(idx) = S;
    
    clear S % Just in case...
end
clear idx

% Remove till and rough pasture columns from feed impact array
GW_feed_farms(:,[3,4]) = [];
ED_feed_farms(:,[3,4]) = [];
WD_feed_farms(:,[3,4]) = [];

% Combine manure vol and leach N2O into total indirect N2O
GW_manure_farms(:,3) = GW_manure_farms(:,3) + GW_manure_farms(:,4);
GW_manure_farms(:,4) = []; % Erase last column

% Determine relative impacts of feed, manure, and operations
for idx = 1 : n_farms
    
    GW_feed_farms(idx,:) = GW_feed_farms(idx,:) ./ sum(GW_feed_farms(idx,:));
    ED_feed_farms(idx,:) = ED_feed_farms(idx,:) ./ sum(ED_feed_farms(idx,:));
    WD_feed_farms(idx,:) = WD_feed_farms(idx,:) ./ sum(WD_feed_farms(idx,:));
    
    GW_manure_farms(idx,:) = GW_manure_farms(idx,:) ./ sum(GW_manure_farms(idx,:)); 
    
    GW_oper_farms(idx,:) = GW_oper_farms(idx,:) ./ sum(GW_oper_farms(idx,:));
    ED_oper_farms(idx,:) = ED_oper_farms(idx,:) ./ sum(ED_oper_farms(idx,:));
    WD_oper_farms(idx,:) = WD_oper_farms(idx,:) ./ sum(WD_oper_farms(idx,:));

end
clear idx


%% EXTRACT MORE RESULTS FROM STRUCT G

alloc_farms = [G.meat_alloc]'; %Allocation value

% Loop through G for extracting values from arrays (stored in G)
for idx = 1 : n_farms

    % Total DMI per head [kg/hd/d]
    % Format: [adult ewe, adult ram, lamb ewe, lamb ram]
    feed_farms(idx, 1:4) = G(idx).feed_per_head;
    
    % Net / gross energy requirements [MJ/hd/d]
    % Format: [adult ewe, adult ram, lamb ewe, lamb ram]
    NE_m_farms(idx,1:4) = G(idx).NE_m; % NE maintenance
    NE_a_farms(idx,1:4) = G(idx).NE_a; % NE activity
    NE_g_farms(idx,1:4) = G(idx).NE_g; % NE growth
    NE_l_farms(idx,1:4) = G(idx).NE_l; % NE lactation
    NE_p_farms(idx,1:4) = G(idx).NE_p; % NE pregnancy
    NE_w_farms(idx,1:4) = G(idx).NE_wool; % NE wool
    GE_farms(idx,1:4) = G(idx).GE; % Gross energy
    
    % Digestible energy [%]
    % Format: [adult ewe, adult ram, lamb ewe, lamb ram]
    DE_farms(idx,1:4) = G(idx).DE; 
    
    % Ent.Ferm [kg CH4/hd/d]
    % Format: [adult ewe, adult ram, lamb ewe, lamb ram]
    EntFerm_farms(idx,1:4) = G(idx).EntFerm;
    
    % Percent of feed from roughage/grazing
    % Format [adult ewe, adult ram, lamb ewe, lamb ram]
    P_forage_farms(idx,:) = G(idx).P_forage;
    
end

% Sheep BW [kg] array, format: [ewe, ram, lamb ewe, lamb ram]
BW_farms = [[G.BW_ewe]', [G.BW_ram]', [G.BW_lamb_ewe]', [G.BW_lamb_ram]'];

% Daily feed as a percent of body weight
feed_per_BW_farms = feed_farms ./ BW_farms;

% Sheep pop array, format: [ewe, ram, lamb ewe, lamb ram]
pop_farms = [[G.ewes]', [G.rams]', [G.lambs]', [G.lambs]'];

% Total NE on farm [MJ/d]
for idx = 1 : n_farms
    
    NE_m_total(idx,1) = sum( NE_m_farms(idx,:) .* pop_farms(idx,:) ); 
    NE_a_total(idx,1) = sum( NE_a_farms(idx,:) .* pop_farms(idx,:) ); 
    NE_g_total(idx,1) = sum( NE_g_farms(idx,:) .* pop_farms(idx,:) ); 
    NE_l_total(idx,1) = sum( NE_l_farms(idx,:) .* pop_farms(idx,:) );
    NE_p_total(idx,1) = sum( NE_p_farms(idx,:) .* pop_farms(idx,:) );
    NE_w_total(idx,1) = sum( NE_w_farms(idx,:) .* pop_farms(idx,:) );
    
end

% Total combined NE on farm
NE_total = NE_m_total + NE_a_total + NE_g_total + NE_l_total + ...
           NE_p_total + NE_w_total;
       
% Percent of NE on farm associated with:
% [NE maint, NE act, NE growth, NE lact, NE preg, NE wool]
p_NE_total = [NE_m_total, NE_a_total, NE_g_total, NE_l_total,...
              NE_p_total, NE_w_total] ./ NE_total;

          
% Manure emissions using arrayfun (avoid for loop)
% Fromat: [ewe, ram, lamb ewe, lamb ram]
% Nitrogen excretion rate (Nex [kg N / 1000 kg BW / day]
Nex_farms = arrayfun(@(a) a.Nex, G, 'UniformOutput', false)';
Nex_farms = cell2mat(Nex_farms);
% Convert [kg N/head/year] to [kg N/1000 kg BW/day]
N_excr_farms = Nex_farms ./ BW_farms * (1000/365);

% Manure CH4 [kg CH4/hd/d]
manure_CH4_farms = arrayfun(@(a) a.manure_CH4,G,'UniformOutput',false);
manure_CH4_farms = cell2mat(manure_CH4_farms(:));

% Manure direct N2O [kg N2O/hd/d]
manure_d_N2O_farms = arrayfun(@(a) a.manure_direct_N2O,G,'UniformOutput',false);
manure_d_N2O_farms = cell2mat(manure_d_N2O_farms(:));
          
% Manure vol. (indirect) N2O [kg N2O/hd/d]
manure_vol_N2O_farms = arrayfun(@(a) a.manure_N2O_vol,G,'UniformOutput',false);
manure_vol_N2O_farms = cell2mat(manure_vol_N2O_farms(:));

% Manure leaching. (indirect) N2O [kg N2O/hd/d]
manure_leach_N2O_farms = arrayfun(@(a) a.manure_N2O_leach,G,'UniformOutput',false);
manure_leach_N2O_farms = cell2mat(manure_leach_N2O_farms(:));

% Total indirect (volatization + leaching) manure N2O [kg N2O/hd/d]
manure_id_N2O_farms = manure_vol_N2O_farms + manure_leach_N2O_farms;



%% EXPORT RESULTS

% Combine NE into array
NE_farms = [NE_m_farms, NE_a_farms, NE_g_farms(:,[3,4]), NE_l_farms(:,1),...
            NE_p_farms(:,1), NE_w_farms];

% Worksheet name where data is exported
ws_name = 'MATLAB_output_farmdata';
        
%
% Concatenate results
xl_out = horzcat(alloc_farms, GW_FU_farms, ED_FU_farms(:,[2,4,5]),WD_FU_farms(:,[2,4,5]),...
                 P_forage_farms, feed_farms, feed_per_BW_farms,...
                 NE_farms, p_NE_total, GE_farms, DE_farms, EntFerm_farms,...
                 manure_CH4_farms, manure_d_N2O_farms, manure_id_N2O_farms,...
                 GW_feed_farms, ED_feed_farms, WD_feed_farms,...
                 GW_manure_farms, GW_oper_farms, ED_oper_farms, WD_oper_farms)';

% Export results
writematrix(xl_out, spreadsheet_name, 'Sheet', ws_name, ...
    'Range', 'C2');

%}

%{ The following lines are intended for graphing / statistical analyses.
% They are not necessary to output the LCA results
% Remove the comment blocks surrounding them to execute them
%}

%% BOXPLOT OF IMPACTS
%{
% Create output result array to be plotted
% Format: [PMA meat, GW, ED, WD]
res_array = [100*[G.meat_alloc]', GW_FU_farms(:,5),...
             ED_FU_farms(:,5), WD_FU_farms(:,5)];
         
% Number of figure rows, col, and starting position
rows = 1; cls = width(res_array); p = 1;

% Figure size
xstart = 100; ystart = 100; xend = 800; yend = 250;

% Create a new figure
figure('DefaultAxesFontSize',12)
set(gcf,'Position',[xstart ystart xend yend])

% Create y-label
ylab = {sprintf('Protein Alloc. (PMA) - Meat\n[%%]'),...
        sprintf('Global Warming (GW)\n[kg CO_2 eq / kg LW]'),...
        sprintf('Energy Demand (ED)\n[MJ / kg LW]'),...
        sprintf('Water Depletion (WD)\n[m^3 / kg LW]')};

% Create x-label
xlab = {'a)', 'b)', 'c)', 'd)'};

for z = 1 : width(res_array) % For each result to be plotted...
    
    % Subplot position
    subplot(rows, cls, p)
    
    % Boxplot
    bp = boxplot(res_array(:,z),'Widths',0.75);

    % Plot data points
    hold on
    
    % Create scatter of datapoints
    xcenter = 1:numel(res_array(:,z));
    spread = 0.5; % 0=no spread; 0.5=random spread within box bounds (can be any value)
    for i = 1:numel(res_array(:,z))
        
        plt = scatter(rand(size(res_array(:,z)))*spread -(spread/2) + xcenter(i),...
             res_array(:,z), 12,'MarkerEdgeColor','k','MarkerEdgeAlpha',0.8);
        
    end
    
    % Format figure
    set(gcf,'Position',[xstart ystart xend yend])
    set(gca,'xticklabel',[])
    set(gca,'xlabel',[])
    set(gca,'ylabel',[])
    xlabel(xlab(z),'FontSize',12)
    ylabel(ylab(z),'FontSize',12)
    
    hold off
    
    p = p + 1; % Increase plot position index
    
end
%}



%{
%% IMPORT RESULTS FROM EXCEL - FOR PLOTTING (Plot table - PT)

PT = readtable(spreadsheet_name, 'Sheet', ws_name,...
    'PreserveVariableNames',true);

% Remove data from empty and last rows
PT([n_farms+1:height(PT)],:) = [];

% Remove first (n) column
PT(:,1) = [];

% Extract variable names in a cell array
varname = PT.Properties.VariableNames;


%% OUTPUT HISTOGRAM SETUP

% Number of figure rows and columns
rows = 4; cls = 6;

% Figure size
xstart = 100; ystart = 100; xend = 1600; yend = 1000;

% Total number of variables/plots
n = length(varname);

% Starting figure window number and plotting positiion
fig_n = 1; p = 1;


%% PLOT HISTOGRAM

% Create a new figure
figure(fig_n)
set(gcf,'Position',[xstart ystart xend yend])


for idx1 = 1 : n
    
    % Subplot position
    subplot(rows, cls, p)
    
    % Plot histogram with fitted disstribution
    h = histfit( table2array ( PT(:,idx1) ) );
    h(1).FaceAlpha = 0.1;
    h(2).Color = 'black';
    h(2).LineWidth = 0.5;
    
    % Plot histogram
    %h = histogram( table2array (PT(:,idx1)), 'BinMethod', 'fd');
    %h.FaceAlpha = 0.01; % Transparency
    
    % Get rid of axis and add title
    %set(gca,'xticklabel',[])
    %set(gca,'xlabel',[])
    %set(gca,'yticklabel',[])
    %set(gca,'ylabel',[])
    title(varname(idx1))  
    
    p = p + 1; % Increase plot position index
    
    % Create new figure window if plot position overflows
    if mod(idx1, rows*cls) == 0
        
        % Create new figure window
        fig_n = fig_n + 1;
        figure(fig_n)
        set(gcf,'Position',[xstart ystart xend yend])
        
        p = 1; % Reset plot position
        
    end     
end
clear idx fig_n

%}



%% LINEAR REGRESSION ANALYSIS
%{
% Initialize p-value array
pval_impacts = zeros(length(vars), 3); % [GW ED WD]
pval_prod = zeros(length(vars), 2); % [Lambs per ewe, Lamb BW]

% Turn off warnings
warning('off','all')

for idx = 1 : length(vars)
    
    %Life cycle impacts - P-value array
    GW_lmodel = fitlm([G.(vars{idx})]', GW_FU_farms(:,5));
    ED_lmodel = fitlm([G.(vars{idx})]', ED_FU_farms(:,5));
    WD_lmodel = fitlm([G.(vars{idx})]', WD_FU_farms(:,5));
    
    pval_impacts(idx,1) = GW_lmodel.Coefficients.pValue(2);
    pval_impacts(idx,2) = ED_lmodel.Coefficients.pValue(2);
    pval_impacts(idx,3) = WD_lmodel.Coefficients.pValue(2);
    
    % Productivity (lambs per ewe and lamb BW) - P-value array
    lambsperewe_lmodel = fitlm([G.(vars{idx})]', [G.lambs_per_ewe]'); 
    lambBW_lmodel = fitlm([G.(vars{idx})]', [G.BW_lamb_ewe]'); 
    
    pval_prod(idx,1) = lambsperewe_lmodel.Coefficients.pValue(2);
    pval_prod(idx,2) = lambBW_lmodel.Coefficients.pValue(2);
    
end
clear idx

% Turn into cell array
pval_impacts = [vars, num2cell(pval_impacts)]; % GW impacts
pval_prod = [vars, num2cell(pval_prod)]; % Prod. parameters

% Turn on warnings
warning('on','all')

%}




            
toc