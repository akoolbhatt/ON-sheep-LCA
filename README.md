# ON-sheep-LCA
## Sheep LCA model using Ontario-specific sheep farming data

The following script package is intended to be used as supplementary material for the manuscript: Life cycle impacts of sheep sector in Ontario Canada by Akul Bhatt and Bassim Abbassi
This script imports paramter values (representing farming practices and environmental factors) and LCIA impact factors stored in 'MATLAB_inputs.xlsx', and stores them as MATLAB variables. The variables are used as input arguments in the LCA model ('sheep_LCA_model.m'), which outputs life cycle impacts in the categories of global warming (GW), energy demand (ED), and water depletion (WD). Model results deemed imporant are tabulated at the end of this live script. 

### Model file requirements:
- Requires the spreadsheet 'MATLAB_inputs.xlsx'
- Requires the LCA model script 'sheep_LCA_model.m'
- Requires the followings scripts in the 'Modules' folder: 'enteric_ferm.m', 'forage_amount.m', 'manure_mgmt.m', 'LCA_farm_operations.m', 'LCA_feed.m', 'LCA_fertilizer.m', and 'LCA_total_FU.m'
