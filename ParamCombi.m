% Investigate parameters independently
% More data points, but smaller search area

% Best param combination selected:
% N_ii = 1000
% N_rw = 1e5
% N_t  = 1e3
% it's the result with the best SD and computation time tradeoff
% since elapsed time between others is marginally shorter
% but the SD is still in the 0.12 range

% Sim1 only

%% generate data
%% N_ii and N_rw
% params
ra    = [2.5,5.0]*1e-6;
gam   = 2.675e8;
gMax  = 0.5;
delta = 50e-3;
Delta = 100e-3;
tf    = 2*Delta;
D = [2.0,2.0,2.0]*1e-9;
kappa = [1.0,0]*1e-5;
relax = [Inf Inf];

N_t  = 1e3;

tryVal =[5e3,6e3,7e3,8e3,9e3,1e4]; %[1e2,2e2,3e2,4e2,5e2,6e2,7e2,8e2,9e2,1e3,2e3,3e3,4e3,5e3,6e3,7e3,8e3,9e3,1e4];

for i=1:length(tryVal)
    N_ii = tryVal(i);
    N_rw = tryVal(i);
    U = N_rw * N_t;
    %if ~(U > 10^8)
    % begin
    t = linspace(0,tf,N_t);
    U     = N_rw * N_t;

    % substrate
    [X,Y] = meshgrid(linspace(-ra(2)*1.3,ra(2)*1.3,N_ii));
    d = sqrt(X.^2+Y.^2);
    I = uint8(d<=ra(2)) + uint8(d<ra(1));

    % sequence
    gRes = 0.001; gSteps = gMax/gRes;
    G=0*t; G(t<=delta)=1; G(t>=Delta&t<=Delta+delta)=-1;
    dir=[1,0]; G=kron(dir,G');
    seq.G = G; seq.t = t; seq.G_s = 0:gRes:gMax;
    bVal = (gam^2 * seq.G_s.*seq.G_s * delta^2 * (Delta - delta/3));

    % analytical
    if ~exist ('Sa','var') % debugging - save time
        ML.d = 2; ML.r = ra; ML.D = [D(1), D(2)]; ML.W = [kappa(1),kappa(2)]; ML.T = relax;
        Sa = ML_compute(seq.G_s,delta,Delta,ML);
    end

    % simulation
    tic
    simu.r = X(1,2)-X(1,1);
    simu.N = N_rw;
    simu.D = D;
    simu.P = flip([ML.W; flip(ML.W)]);
    S = diffSim(I,seq,simu,gam);
    elapsedTime = toc;
    save(sprintf('Results/Params/Combi/Nii=%d Nrw=%d',N_ii,N_rw)); % save                                                                                                                                                                                                                                                                                          
    %else
    %fprintf("Skipped N_rw = %d and N_t = %d\n", N_rw, N_t);                                                                                                       
    %end
end

%% N_rw and N_t
% params
ra    = [2.5,5.0]*1e-6;
gam   = 2.675e8;
gMax  = 0.5;
delta = 50e-3;
Delta = 100e-3;
tf    = 2*Delta;
D = [2.0,2.0,2.0]*1e-9;
kappa = [1.0,0]*1e-5;
relax = [Inf Inf];

N_ii = 1000;
tryVal = [1e2,2e2,3e2,4e2,5e2,6e2,7e2,8e2,9e2,1e3,2e3,3e3,4e3,5e3,6e3,7e3,8e3,9e3,1e4]; %[1e2, 5e2, 1e3, 5e3, 1e4, 5e4, 1e5, 5e5];

for i=1:length(tryVal)
    N_rw = tryVal(i); N_t = tryVal(i);
    %U     = N_rw * N_t;
    %if ~(U > 10^8)
    % begin
    t = linspace(0,tf,N_t);
    U     = N_rw * N_t;

    % substrate
    [X,Y] = meshgrid(linspace(-ra(2)*1.3,ra(2)*1.3,N_ii));
    d = sqrt(X.^2+Y.^2);
    I = uint8(d<=ra(2)) + uint8(d<ra(1));

    % sequence
    gRes = 0.001; gSteps = gMax/gRes;
    G=0*t; G(t<=delta)=1; G(t>=Delta&t<=Delta+delta)=-1;
    dir=[1,0]; G=kron(dir,G');
    seq.G = G; seq.t = t; seq.G_s = 0:gRes:gMax;
    bVal = (gam^2 * seq.G_s.*seq.G_s * delta^2 * (Delta - delta/3));

    % analytical
    if ~exist ('Sa','var') % debugging - save time
        ML.d = 2; ML.r = ra; ML.D = [D(1), D(2)]; ML.W = [kappa(1),kappa(2)]; ML.T = relax;
        Sa = ML_compute(seq.G_s,delta,Delta,ML);
    end

    % simulation
    tic
    simu.r = X(1,2)-X(1,1);
    simu.N = N_rw;
    simu.D = D;
    simu.P = flip([ML.W; flip(ML.W)]);
    S = diffSim(I,seq,simu,gam);
    elapsedTime = toc;
    save(sprintf('Results/Params/Combi/Nrw=%d Nt=%d',N_rw,N_t)); % save                                                                                                                                                                                                                                                                                          
    %else
    %fprintf("Skipped N_rw = %d and N_t = %d\n", N_rw, N_t);                                                                                                       
    %end
end

%% N_t and N_ii
% params
ra    = [2.5,5.0]*1e-6;
gam   = 2.675e8;
gMax  = 0.5;
delta = 50e-3;
Delta = 100e-3;
tf    = 2*Delta;
D = [2.0,2.0,2.0]*1e-9;
kappa = [1.0,0]*1e-5;
relax = [Inf Inf];

N_rw  = 1e5;
tryVal = [5e3];

for i=1:length(tryVal)    
    %if ~(U > 10^8)
    % begin
    N_ii = tryVal(i); N_t  = tryVal(i);
    t    = linspace(0,tf,N_t);
    U    = N_rw * N_t;

    % substrate
    [X,Y] = meshgrid(linspace(-ra(2)*1.3,ra(2)*1.3,N_ii));
    d = sqrt(X.^2+Y.^2);
    I = uint8(d<=ra(2)) + uint8(d<ra(1));

    % sequence
    gRes = 0.001; gSteps = gMax/gRes;
    G=0*t; G(t<=delta)=1; G(t>=Delta&t<=Delta+delta)=-1;
    dir=[1,0]; G=kron(dir,G');
    seq.G = G; seq.t = t; seq.G_s = 0:gRes:gMax;
    bVal = (gam^2 * seq.G_s.*seq.G_s * delta^2 * (Delta - delta/3));

    % analytical
    if ~exist ('Sa','var') % debugging - save time
        ML.d = 2; ML.r = ra; ML.D = [D(1), D(2)]; ML.W = [kappa(1),kappa(2)]; ML.T = relax;
        Sa = ML_compute(seq.G_s,delta,Delta,ML);
    end

    % simulation
    tic
    simu.r = X(1,2)-X(1,1);
    simu.N = N_rw;
    simu.D = D;
    simu.P = flip([ML.W; flip(ML.W)]);
    S = diffSim(I,seq,simu,gam);
    elapsedTime = toc;
    save(sprintf('Results/Params/Combi/Nt=%d Nii=%d',N_t,N_ii)); % save                                                                                                                                                                                                                                                                                          
    %else
    %fprintf("Skipped N_rw = %d and N_t = %d\n", N_rw, N_t);                                                                                                       
    %end
end
%fprintf("\nTotal experiments: %d",E);

%% Data anaylsis

% N_ii and N_rw
clear; folder = (dir("Results/Params/Combi/Nii and Nrw/")); names = extractfield(folder(3:length(folder)),'name')'; num = length(names);
Nii      = zeros(num,1);
MRAE     = zeros(num,1);
compTime = zeros(num,1);
SD       = zeros(num,1);
for val=1:num
    load(char(names(val)));
    Nii(val) = N_ii;
    MRAE(val) = mean((abs((Sa-real(S'))./Sa)));
    compTime(val) = elapsedTime;
    SD(val) = std(real(S'));
end
[Nii,idx] = sort(Nii); errVals = MRAE(idx);
figure; plot(errVals)
ylabel('MRAE'), set(gca,'XTickLabel',(erase(names(idx),".mat"))), set(gca,'XTickLabelRotation',45);
figure; [bestTimes,idx2] = sort((compTime),'ascend'), hold on, bestTimesName=(erase(names(idx2),".mat"));
barh(bestTimes,0.2), set(gca,'YTickLabel',bestTimesName); xlabel('Elapsed time (s)'), set(gca,'YTickLabelRotation',45);
%ax = gca; ax.XLim = [20 27]; clear gca;




% N_rw and N_t



% N_t and N_ii








% %% Nii
% clear; folder = (dir("Results/Params/Nii/"));
% names = extractfield(folder(3:length(folder)),'name')';
% num = length(names);
% 
% Nii      = zeros(num,1);
% MRAE     = zeros(num,1);
% compTime = zeros(num,1);
% SD       = zeros(num,1);
% 
% for val=1:num
%     load(char(names(val)));
%     Nii(val) = N_ii;
%     MRAE(val) = mean((abs((Sa-real(S'))./Sa)));
%     compTime(val) = elapsedTime;
%     SD(val) = std(real(S'));
% end
% [Nii,idx] = sort(Nii); errVals = MRAE(idx);
% figure; plot(errVals)
% ylabel('MRAE'), set(gca,'XTickLabel',(erase(names(idx),".mat"))), set(gca,'XTickLabelRotation',45);
% 
% figure; [bestTimes,idx2] = sort((compTime),'ascend'), hold on, bestTimesName=(erase(names(idx2),".mat"));
% barh(bestTimes,0.2), set(gca,'YTickLabel',bestTimesName); xlabel('Elapsed time (s)'), set(gca,'YTickLabelRotation',45);
% ax = gca; ax.XLim = [20 27]; clear gca;
% 
% %% Nrw
% clear; folder = (dir("Results/Params/Nrw/"));
% names = extractfield(folder(3:length(folder)),'name')';
% num = length(names);
% 
% Nrw      = zeros(num,1);
% MRAE     = zeros(num,1);
% compTime = zeros(num,1);
% 
% for val=1:num
%     load(char(names(val)));
%     Nrw(val) = N_ii;
%     MRAE(val) = mean((abs((Sa-real(S'))./Sa)));
%     compTime(val) = elapsedTime;
% end
% [Nrw,idx] = sort(Nrw); errVals = MRAE(idx);
% figure; semilogy(errVals)
% ylabel('MRAE'), set(gca,'XTickLabel',(erase(names(idx),".mat"))), set(gca,'XTickLabelRotation',45);
% 
% [bestTimes,idx2] = sort((compTime),'ascend'), hold on, bestTimesName=(erase(names(idx2),".mat"));
% figure; semilogy(bestTimes),set(gca,'XTickLabel',bestTimesName), ylabel('Elapsed time (s)'),set(gca,'XTickLabelRotation',45)
% %barh(bestTimes,0.2), set(gca,'YTickLabel',bestTimesName); xlabel('Elapsed time (s)'), set(gca,'YTickLabelRotation',45);
% 
% %% Nt
% clear; folder = (dir("Results/Params/Nt/"));
% names = extractfield(folder(3:length(folder)),'name')';
% num = length(names);
% 
% Nt      = zeros(num,1);
% MRAE     = zeros(num,1);
% compTime = zeros(num,1);
% 
% for val=1:num
%     load(char(names(val)));
%     Nt(val) = N_t;
%     MRAE(val) = mean((abs((Sa-real(S'))./Sa)));
%     compTime(val) = elapsedTime;
% end
% [Nt,idx] = sort(Nt); errVals = MRAE(idx);
% figure; semilogy(errVals)
% ylabel('MRAE'), set(gca,'XTickLabel',(erase(names(idx),".mat"))), set(gca,'XTickLabelRotation',45);
% 
% %% clean files!!!
% % clear dir; clearFolder = (dir("Results/Params/Nt/")); clearName = extractfield(clearFolder(3:length(clearFolder)),'name')';
% % for i=1:length(clearName)
% %     load(char(clearName(i)));
% %     clearvars disks E dir bestTimes bestTimesName compTime errVals fileName fileNames folder id idx item k loadFolder mean_compTime mean_SD MRAE N_params N_trials repeatReadings rpt SD SDvals names
% %     save(sprintf('Results/Params/Nt/%s',char(clearName(i))))
% % end

%% Correlation
% what we really want to be doing for an effective bivariate comparison





