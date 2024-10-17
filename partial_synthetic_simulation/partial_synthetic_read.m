%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Simulation Code for ML NOE(-1.6) imaging using partially synthetic data
%
% Authors: Leqi Yin, Zhongliang Zu
%
% Correspondance: zhongliang.zu@vumc.org 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc

% Load the file containing the variables of fitted pools for tissue-mimicking
% data or invivo data, and fm information
load("")


% tt mean saturation power (uT)
tt=1;  
% pulse duration is the total saturation time (s)
pulseduration=5;
% noise
i_SNR=5.0;

B0_sythetic=4.7;
delB0=B0_sythetic/9.4;
offppm=200;

Omax=2000;
step=50;
sep1=3.6*offppm;
sep2=3*offppm;
sep3=2*offppm;
sep4=-1.6*offppm;
sep5=-3.3*offppm;

% creating frequency offset
offset= -Omax:step:Omax;
k_0=[-4000, -3500, -3000, -2500, offset, 2500, 3000,3500,4000]*delB0;




num_T1W=5;
num_T2W=5;
num_R2S4=4;
num_fs2=4;
num_fs4=5;
num_fs5=4;
num_fm=4;
num_offV=5;



fs2_matrix=[0.5, 0.8, 1.1, 1.4];
fs4_matrix=[0.0004, 0.0008, 0.0015, 0.003, 0.006]; 
fs5_matrix=[0.5, 0.8, 1.1, 1.4];
fm_matrix=[0.5, 0.8, 1.1, 1.4];
fm=mean(fm_matrix);

ksw4=50;

T1W_matrix=[1.5,1.7,1.9,2.1,2.3];
T2W_matrix=[50,70,90,110,130]*0.001;
R2S4_matrix=[1/0.002,1/0.003,1/0.004,1/0.005];
R1M=1/1.5;

% varied offset(B0 shift)
offV_matrix=[-40,-20,0,20,40];

% randomly select pools information from 100 voxels; value assigned can be changed
total_voxels=100;
randidx=randperm(length(mor_AREX_amide),total_voxels);

% use the average of fitted pools to generate partially synthetic data;
% fitted pools should be from the loaded file
Amine_MR=mean(mor_AREX_amine(:,randidx),2)';
NOE3p5_MR=mean(mor_AREX_NOE3p5(:,randidx),2)';
MT_MR=mean(mor_MT(:,randidx),2)';


i = 1;

for ii_T1W=1:num_T1W
    R1W_cal=1./T1W_matrix(ii_T1W);
    for ii_T2W=1:num_T2W
        R2W_cal=1./T2W_matrix(ii_T2W);
        for ii_fs2=1:num_fs2
            fs2_cal=fs2_matrix(ii_fs2);
            for ii_fs5=1:num_fs5
                fs5_cal=fs5_matrix(ii_fs5);
                for ii_fm=1:num_fm
                    fm_cal=fm_matrix(ii_fm);
                    for ii_R2S4=1:num_R2S4
                        R2S4_cal=R2S4_matrix(ii_R2S4);
                        for ii_fs4=1:num_fs4
                            fs4_cal=fs4_matrix(ii_fs4);
                            for ii_offV=1:num_offV
                                offV=offV_matrix(ii_offV);

                                                                                   

 k=k_0 + offV;

 % apparent R1W
 R1W_cal_obs=(R1W_cal+fm_cal*fm*R1M)./(1+fm_cal*fm); 

 cal_Lorentzian2_cal=fs2_cal*Amine_MR;
 cal_Lorentzian4_cal=(fs4_cal.*ksw4.*(tt.*42.6*2*pi).^2./((tt.*42.6*2*pi).^2+(R2S4_cal+ksw4)*ksw4+ksw4./(R2S4_cal+ksw4).*((k_0+sep4)*2*pi).^2));
 cal_Lorentzian5_cal=fs5_cal*NOE3p5_MR;
 cal_Lorentzian6_cal=fm_cal*MT_MR;
 cal_eff_cal=R1W_cal_obs.*((k_0)*2*pi).^2./((tt.*42.6*2*pi).^2+((k_0)*2*pi).^2)+R2W_cal.*(tt.*42.6*2*pi).^2./((tt.*42.6*2*pi).^2+((k_0)*2*pi).^2);
 
 sscal=R1W_cal_obs./(cal_eff_cal+cal_Lorentzian2_cal./(1+fm_cal*fm)+cal_Lorentzian4_cal./(1+fm_cal*fm)+cal_Lorentzian5_cal./(1+fm_cal*fm)+cal_Lorentzian6_cal).*(((k_0)*2*pi).^2./((tt.*42.6*2*pi).^2+((k_0)*2*pi).^2));
 sscal_VO=interp1(k_0, sscal,k);
 SS_cal_matrix(:,i)=sscal_VO;


 AREX_amp_matrix(i)=(fs4_cal.*ksw4.*(tt.*42.6*2*pi).^2./((tt.*42.6*2*pi).^2+(R2S4_cal+ksw4)*ksw4));
 AREX_width_matrix(i)=2*sqrt((tt.*42.6*2*pi).^2.*(R2S4_cal+ksw4)/ksw4+(ksw4+R2S4_cal)^2);

 R1W_cal_matrix(i)=R1W_cal_obs;
 fm_cal_matrix(i)=fm_cal*fm;
 



 i = i+1;
                                     
                            end
                        end
                    end
                end
            end
        end
    end
end

% Set Nah to 0.9 for training
SS_cal_SS_cal_matrix(isnan(SS_cal_matrix)) = 0.9;

% Save the following variables as input and target for training
DL_Input_training_clean=SS_cal_matrix;
DL_Output_training=[AREX_amp_matrix;AREX_width_matrix];
DL_R1W=R1W_cal_matrix;


