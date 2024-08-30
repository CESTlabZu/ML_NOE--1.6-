# Improving quantification accuracy of a Nuclear Overhauser Enhancement imaging at -1.6 ppm at 4.7T using a Machine Learning Approach

###
This project focuses on using a Machine Learning (ML) model trained on partially synthetic Chemical Exchange Saturation Transfer (CEST) data combined with a curriculum learning denoising approach to predict Nuclear Overhauser Enhancement imaging at -1.6 ppm. Please refer to the detailed instructions below if necessary.

![CEST flow chart_NOE-1 6](https://github.com/user-attachments/assets/debdc61d-2865-4eae-80df-cafcb45b59c5)

## Detailed instructions for using code and data
### Partial Synthetic Simulation
To use in-vivo data, locate the file **invivo_4p7T_7rats_1D** in the **invivo_data** folder. For tissue-mimicking data, save the variables for fitted Amine, NOE(-3.5), MT, and fm information. Load the relevant data in **partial_synthetic_read.m**.
Input the variables for fitted Amine, NOE-3.5, MT, and fm information and save the variables for training.
### Fully Synthetic Simulation
Comment or uncomment the lines as needed for different simulations. Run the code and save the variables for training.
### Tissue-mimicking Simulation
Run the code and save the variables for Zspectra, fm information, and R1W information for the multiple-pool model Lorentzian fit. Additionally, save the ground truth NOE(-1.6) variable for measuring the loss between the ML prediction and the multiple-pool model Lorentzian fit.
Load the variables for Zspectra, fm information, and R1W information in **mplf.m**.
Save the variables for fitted Amine, NOE(-3.5), MT, and fm information and load them in **partial_synthetic_read.m** for partially synthetic data simulation.
### ML training
Load the training data, including inputs and targets, in **training_read.m** and run the code.
Save the trained network and use it to predict the testing data to evaluate its performance.
