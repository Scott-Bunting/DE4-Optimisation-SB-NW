# This is the README for Subsystem 2

*Subsystem 2 is the Rotors subsystem, consisting of a multi-objective mass and cost optimisation*

## Main Script

There are three scripts here. Rotors_1 (report and corrected) and Rotors_2.
  
Rotors 1 is the single material optimisation. 
When prompted to select a material, enter 1 for Carbon-Fibre Reinforced Plastic.  
*This script runs SQP as default. This can be edited in the code by changing the index of the algorithms list.*   
  
Rotors 2 is the multi-material optimisation, using the mat_par file, plotting the materials and selecting the lightest one.  
When prompted to select an algorithm, enter 2 for SQP.  

*Rather than simply optimising for mass, which was the primary objective of the study, this code could be adapted to make an optimal selection based on cost*  

## Execution Time

### Rotors_1_report, Rotors_2_corrected
2-5 Seconds with SQP

### Rotors_2
Less than 10 Seconds with SQP

## Dependencies

The script requires MATLAB R2018b.
* Global Optimisation Toolbox required
