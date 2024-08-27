%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Training Code for ML NOE(-1.6) imaging
% Please comment or uncomment the required lines of text if needed
%
% Authors: Leqi Yin, Zhongliang Zu
%
% Correspondance: zhongliang.zu@vumc.org 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Requires Deep Learning Toolbox
clear;
clc;
tic

% load clean data for training
load("trainingdata_TM_4p7T_VO_63011_JU5.mat")

% training data type, set its value to 1 for Amplitude, 2 for width
trainingdata = 1;

% signal-to-noise ratio
i_SNR = 5;

% offset cut
k_cut = [1:5,51:89]; 

n_features = length(k_cut);
n_outputs = 1;

% training model set up
layers = [...
    sequenceInputLayer(n_features,Normalization="zerocenter")

    convolution1dLayer(3,64,"Padding","same","WeightsInitializer","he")
    eluLayer

    convolution1dLayer(3,32,"Padding","same","WeightsInitializer","he")
    eluLayer

    convolution1dLayer(3,16,"Padding","same","WeightsInitializer","he")
    eluLayer

    flattenLayer
    
    dropoutLayer(0.15)

    fullyConnectedLayer(256)

    fullyConnectedLayer(128)

    fullyConnectedLayer(n_outputs)

    regressionLayer

];

% curriculum learning 
% 1000 epochs in the initial iteration and 100 epochs in subsequent iterations
for ii = 1:4
if ii >1 
    numEpoch = 100;
else
    numEpoch = 1000;
end

% add increasing noise to the data
noiseadd = (ii-1)*0.001
for pp = 1:length(DL_Input_training_clean)
       rng(pp+666*ii);
       DL_Input_training_noise(:,pp) = DL_Input_training_clean(:,pp) + ((noiseadd+ (noiseadd*(i_SNR-1)))*randn(size(DL_Input_training_clean(:,1)))); 
end

% training data preprocessing
DL_Input_training = DL_R1W./DL_Input_training_noise(k_cut,:);

matrix_inp = DL_Input_training;

% Target matrix
rawDataTarget = DL_Output_training(trainingdata,:);
rawDataTrain = matrix_inp;

n_timesteps = size(matrix_inp,2);
n_features = size(matrix_inp,1);
n_outputs = size(rawDataTarget,1);
idx = 1:n_timesteps;


% Training and Validation Data

Randidx = [round(n_timesteps*0.05)+1:round(n_timesteps*0.1),...
    round(n_timesteps*0.7)+1:round(n_timesteps*0.8)];
Valididx = intersect(idx,Randidx);
Dataidx = setdiff(idx,Randidx);
DataTrain = rawDataTrain(:,Dataidx);  
ValidDataTrain = rawDataTrain(:,Valididx);

if trainingdata == 2
    % standardize data becasue of its high std
    DataTarget = rawDataTarget(1, Dataidx)./300;
    ValidDataTarget = rawDataTarget(1, Valididx)./300;
else
    DataTarget = rawDataTarget(1, Dataidx);
    ValidDataTarget = rawDataTarget(1, Valididx);
end



% training options
    options = trainingOptions('adam', ...
    'MaxEpochs',numEpoch, ...
    'MiniBatchSize',32, ...
    'InitialLearnRate',0.001, ...
    'ValidationData',{ValidDataTrain, ValidDataTarget}, ...
    'ValidationFrequency',100, ...
    'Shuffle', 'every-epoch', ... % Shuffle the data at every epoch
    'Plots', 'training-progress', ...
    'Verbose', true ...
    );


net = trainNetwork(DataTrain, DataTarget, layers, options);	
lgraph = layerGraph(net);
layers = net.Layers;


% uncomment the following lines to enable predictions on the testing data

% if trainingdata == 2
%     % revert the prediction results to their original scale
%     DL_pred = predict(net, DL_Input_testing).*300;
% else
%     DL_pred = predict(net, DL_Input_testing);
% end


end

