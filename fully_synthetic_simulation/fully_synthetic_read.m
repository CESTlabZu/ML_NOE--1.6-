%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Simulation Code for ML NOE(-1.6) imaging using fully synthetic data
% Please comment or uncomment the required lines of text if needed
%
% Authors: Leqi Yin, Zhongliang Zu
%
% Correspondance: zhongliang.zu@vumc.org 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

% tt mean saturation power (uT)
tt=1;
% pulse duration is the total saturation time (s)
pulseduration=5;
% noise
i_SNR=5;  
gauss=100;

% create frequency offset 
maxf=1000;
step=25;
offset=-maxf:step:maxf;
k_4p7T=[-2000, -1750, -1500, -1250, offset, 1250, 1500,1750,2000]';
satangle=tt*42.6*360*pulseduration;

% frequency offset of each pool
sep1_4p7T=3.6*200;  %amide
sep2_4p7T=3*200; %fast amine
sep3_4p7T=2*200;  % creatine amine
sep4_4p7T=-1.6*200; % NOE at -1.6
sep5_4p7T=-3.3*200; % NOE at -1.6

% relaxations
R1S=1/1.5;
R2S1=1/0.004;
R2S2=1/0.01;
R2S3=1/0.01;
R2S5=1/0.0008;
R1M=1/1.5;
R2M=1/0.00006;


fs1=0.001;
fs2=0.003;
fs3=0.0003;
ksw1=100;
ksw2=5000;
ksw3=300;
ksw4=50;
ksw5=20;
kmw=35;


num_T1W=5;
num_T2W=5;
num_fs2=4;% comment for decreased loop parameters - type 2
num_fs3=3;
num_fs4=5;
num_fs5=4;
num_fm=4;
num_T2S4=4;
num_offvar=5;

T1W_matrix=[1.5,1.7,1.9,2.1,2.3];
T2W_matrix=[50,70,90,110,130]*0.001;
T2S4_matrix=[0.002, 0.003, 0.004, 0.005];

fs2_matrix=[0.5, 0.8, 1.1, 1.4]*0.003;% comment for type 2
fs3_matrix=[0.0001, 0.0003, 0.0005];
fs4_matrix=[0.0004, 0.0008, 0.0015, 0.003, 0.006];
fs5_matrix=[0.5, 0.8, 1.1, 1.4]*0.01;
fm_matrix=[0.5, 0.8, 1.1, 1.4]*0.07;

% varied offset(B0 shift)
offV_matrix=[-40,-20,0,20,40];


i=1;
for ii_T1W=1:num_T1W
    R1W=1./T1W_matrix(ii_T1W);
    for ii_T2W=1:num_T2W
        R2W=1./T2W_matrix(ii_T2W);
        for ii_fs2=1:num_fs2
            fs2=fs2_matrix(ii_fs2);
            for ii_fs3=1:num_fs3
                fs3=fs3_matrix(ii_fs3);
                for ii_fs5=1:num_fs5
                    fs5=fs5_matrix(ii_fs5);
                    for ii_fm=1:num_fm
                        fm=fm_matrix(ii_fm);
                        for ii_offvar=1:num_offvar
                            var = offV_matrix(ii_offvar);
                            for ii_T2S4=1:num_T2S4
                                R2S4= 1./T2S4_matrix(ii_T2S4);
                                for ii_fs4=1:num_fs4
                                    fs4=fs4_matrix(ii_fs4);
                          
% apparent R1W
R1W_cal_obs=(R1W+(fm*R1M))./(1+fm); 

a25mspulse=runsteadysimgauss(ksw1, ksw2, ksw3, ksw4, ksw5, kmw, fs1, fs2, fs3,fs4, fs5, 1, fm, R1S, R2S1, R2S2, R2S3,R2S4, R2S5, R1W, R2W, R1M, R2M,sep1_4p7T*2*pi,sep2_4p7T*2*pi,sep3_4p7T*2*pi,sep4_4p7T*2*pi, sep5_4p7T*2*pi, pulseduration, gauss, satangle, 1, 2, 1, .00, 1, 1, (k_4p7T+var)*2*pi, 1);
aa_4p7T_S(:,i)=a25mspulse(:,6);

fm_cal_matrix_S(:,i)=fm;
R1W_cal_matrix_S(:,i)=R1W_cal_obs;
AREX_amp_matrix_S(i) = (fs4.*ksw4.*(tt.*42.6*2*pi).^2./((tt.*42.6*2*pi).^2+(R2S4+ksw4)*ksw4));
AREX_width_matrix_S(i)=2*sqrt((tt.*42.6*2*pi).^2.*(R2S4+ksw4)/ksw4+(ksw4+R2S4)^2);

X = sprintf("-------------------------------------%d",i);
disp(X)
i = i+1;

                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

% Save the following variables as input and target for training.    

DL_Input_training_clean=aa_4p7T_S;
DL_Output_training=[AREX_amp_matrix_S;AREX_width_matrix_S];
DL_R1W=R1W_cal_matrix_S;




 
 
