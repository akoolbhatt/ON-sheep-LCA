# ON-sheep-LCA
## Sheep LCA model using Ontario-specific sheep farming data

This script package is intended to be used as supplementary material for the manuscript: ***Life cycle impacts of sheep sector in Ontario, Canada*** by **Akul Bhatt** and **Bassim Abbassi**

This script package imports parameter values (representing farming practices and environmental factors) and LCIA impact factors stored in `MATLAB_inputs.xlsx`, and stores them as MATLAB variables. The variables are used as input arguments in the LCA model (`sheep_LCA_model.m`), which outputs life cycle impacts in the categories of global warming (GW), energy demand (ED), and water depletion (WD). 
 
The live script `sheep_LCA_IO.mlx` may be used as an example to see how input arguments in `MATLAB_inputs.xlsx` can be passed on to the LCA model. Model results deemed important (e.g., life cycle impacts per functional unit, total daily matter intake (DMI), etc.) are also tabulated at the end of this live script. 

### Model file requirements:
The Model input-output live script `sheep_LCA_IO.mlx` requires the following files to work:
- spreadsheet `MATLAB_inputs.xlsx`
- LCA model script `sheep_LCA_model.m`
- The followings scripts in the 'Modules' folder: `enteric_ferm.m`, `forage_amount.m`, `manure_mgmt.m`, `LCA_farm_operations.m`, `LCA_feed.m`, `LCA_fertilizer.m`, and `LCA_total_FU.m`

#### Model input parameter/variable description:
The file `sheep_LCA_model_param_info.pdf` contains description, baseline value, and source of input parameters/variables accepted into the LCA model. The baseline values represent average sheep farming practices in Ontario, Canada.

#### Model script description
- **`sheep_LCA_model.m`**: This script does the following 
   - a) combines related variables into arrays, 
   - b) displays error, aborts calculations if invalid inputs are detected, 
   - c) estimates forage amount through iterative energy balance, and
   - d) runs subsequent scripts in 'Modules' to determine cradle-to-gate life cycle impacts
- **`enteric_ferm.m`**: Calculates livestock's net energy (NE) and gross energy (GE) requirements, and per-head enteric CH4 emissions
- **`'forage_amount.m`**: Estimates DMI from roughage/grazing
- **`manure_mgmt.m`**: Estimates manure CH4 emissions and nitrogen-based GHG emissions (through nitrogen balance)
- **`LCA_feed.m`**: Tallies the total feed intake and calculates impacts of feed production
- **`LCA_fertilizer.m`**: Calculates impacts of fertilizer production and fertilization
- **`LCA_farm_operations.m`**: Calculates impacts of farm infrastructure (outdoor area, barns/sheds, etc) and misc. farming operations (water, electricity, heating fuel, diesel, tilling, plastic, and transportation)
- **`LCA_total_FU.m`**: Calculates allocation factor and estimates life cycle impacts per functional unit
