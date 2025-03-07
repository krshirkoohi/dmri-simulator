% Find the best parameter combination
%% Sim1 (validation)

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
E = 0; % total experiments

for N_ii = [200,500,1000]
    for N_t = [1e2, 1e3, 1e4, 1e5]
        for N_rw = [1e2, 1e3, 1e4, 1e5]
            U     = N_rw * N_t;
            if ~(U > 10^8)
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
                E = E + 1;
                save(sprintf('Results/Sim1/Nii=%d Nrw=1e%d Nt=1e%d',N_ii,log10(N_rw),log10(N_t))); % save                                                                                                                                                                                                                                                                                          
            else
                %fprintf("Skipped N_rw = %d and N_t = %d\n", N_rw, N_t);                                                                                                       
            end
        end
    end
end
%fprintf("\nTotal experiments: %d",E);

%% Sim1 data analysis

% order is not important, this is a brute force method
clear dir; loadFolder = (dir("Results/Sim1"));
fileNames = extractfield(loadFolder(3:length(loadFolder)),'name')'; E = length(fileNames);
MRAE = zeros(E,1);
compTime = zeros(E,1);
for p=1:E
    load(char(fileNames(p)));
    MRAE(p) = mean(abs((Sa-real(S'))./Sa));
    compTime(p) = elapsedTime;
end
[errVals,id] = sort(MRAE); compTime = compTime(id);

% top five lowest error
figure; bar(errVals(1:5),0.2);
ylabel('MRAE'), set(gca,'XTickLabel',erase(fileNames(id(1:5)),".mat")), set(gca,'XTickLabelRotation',45);

% corresponding computation time
figure; [bestTimes,idx] = sort(compTime(id(1:5)),'ascend'), hold on, bestTimesName=(erase(fileNames(id(idx)),".mat"));
barh(bestTimes,0.2), set(gca,'YTickLabel',bestTimesName); xlabel('Elapsed time (s)'), set(gca,'YTick',1:5), set(gca,'YTickLabelRotation',45);

%% Sim2 (stability)
clear;

% physical
ra    = 1e-5;
gam   = 2.675e8;
gMax  = 0.5;
delta = 50e-3;
Delta = 100e-3;
tf    = 2*Delta;
diffu = [2.0,2.0,2.0]*1e-9; %[2.0,2.0]*1e-9;
perma = [1.0,0]*1e-5;
relax = [Inf Inf];

% scan
N_ii  = 1000;
N_rw  = 1e5;
N_t   = 1e3;
repeatReadings = 10;

%for N_ii = [200,500,1000]
%    for N_t = [1e3, 1e4, 1e5]
%        for N_rw = [1e3, 1e4]
for rpt=1:repeatReadings
    t     = linspace(0,tf,N_t);
    U     = N_rw * N_t;
    [X,Y] = meshgrid(linspace(-ra*1.3,ra*1.3,N_ii));
    load(sprintf("Substr/Nii=%d.mat",N_ii));

    % seq
    gRes = 0.001; gSteps = gMax/gRes;
    G=0*t; G(t<=delta)=1; G(t>=Delta&t<=Delta+delta)=-1;
    dir=[1,0]; G=kron(dir,G');
    seq.G = G; seq.t = t; seq.G_s = 0:gRes:gMax;
    bVal = (gam^2 * seq.G_s.*seq.G_s * delta^2 * (Delta - delta/3));

    % sim
    tic
    simu.r = X(1,2)-X(1,1);
    simu.N = N_rw;
    simu.D = diffu;
    simu.P = flip([perma; flip(perma)]);
    S = diffSim(I,seq,simu,gam);
    elapsedTime = toc;
    save(sprintf('Results/Sim2/Nii=%d Nrw=1e%d Nt=1e%d %d',N_ii,log10(N_rw),log10(N_t),rpt)); % save                     
end                                                                                                                               
%        end
%    end
%end

%% Sim2 data analysis
clear;

clear dir; loadFolder = (dir("Results/Sim2"));
fileNames = extractfield(loadFolder(3:length(loadFolder)),'name')'; E = length(fileNames);
MRAE = zeros(E,1);
N_params = 5;
N_trials = 10;
SD = zeros(N_params,N_trials); mean_SD = zeros(N_params,1);
compTime = zeros(N_params,N_trials); mean_compTime = zeros(N_params,1);
names = strings(N_params,1);
for k=1:N_params
    for q=1:N_trials
        item = (k-1)*N_trials+q;
        load(char(fileNames(item)));
        SD(k,q) = std(real(S'));
        compTime(k,q) = elapsedTime;
    end
    names(k) = (erase(fileNames(item)," 9.mat"));
    mean_SD(k) = mean(SD(k,:));
    mean_compTime(k) = mean(compTime(k,:));
end
[SDvals,id] = sort(mean_SD); compTime = compTime(id);
table(names(id),SDvals)

% corresponding computation time
figure; [bestTimes,idx] = sort(compTime(id(1:5)),'ascend'), hold on, bestTimesName=(erase(names(id(idx)),".mat"));
barh(bestTimes,0.2), set(gca,'YTickLabel',bestTimesName); xlabel('Elapsed time (s)'), set(gca,'YTick',1:5), set(gca,'YTickLabelRotation',45);






