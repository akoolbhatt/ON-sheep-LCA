# ON-sheep-LCA
## Sheep LCA model using Ontario-specific sheep farming data

This script package is intended to be used as supplementary material for the manuscript: ***Life cycle impacts of sheep sector in Ontario, Canada*** by **Akul Bhatt** and **Bassim Abbassi**

This script package imports parameter values (representing farming practices and environmental factors) and LCIA impact factors stored in `MATLAB_inputs.xlsx`, and stores them as MATLAB variables. The variables are used as input arguments in the LCA model (`sheep_LCA_model.m`), which outputs life cycle impacts in the categories of global warming (GW), energy demand (ED), and water depletion (WD). 
 
The live script `sheep_LCA_IO.mlx` may be used as an example to see how input arguments in `MATLAB_inputs.xlsx` can be passed on to the LCA model. Model results deemed imporant (e.g., life cycle impacts per functional unit, total daily matter intake, etc.) are also tabulated at the end of this live script. 

### Model file requirements:
The Model input-output live script `sheep_LCA_IO.mlx` requires the following files to work:
- Requires the spreadsheet `MATLAB_inputs.xlsx`
- Requires the LCA model script `sheep_LCA_model.m`
- Requires the followings scripts in the 'Modules' folder: `enteric_ferm.m`, `forage_amount.m`, `manure_mgmt.m`, `LCA_farm_operations.m`, `LCA_feed.m`, `LCA_fertilizer.m`, and `LCA_total_FU.m`

### Model input parameter/variable description:
