% Multi-axonal substrate

%% params

% physical
ra    = 1e-5;
gam   = 2.675e8;
gMax  = 0.5; 
delta = 50e-3;
Delta = 100e-3;
tf    = 2*Delta;
diffu = [2.0,2.0,2.0]*1e-9; 
perma = [1.0,0]*1e-5;
relax = [Inf Inf];

% scan
N_ii  = 300;
N_rw  = 1e4;
N_t   = 1e4;
U     = N_rw * N_t;
t     = linspace(0,tf,N_t);

%% substrate

[X,Y] = meshgrid(linspace(-ra*1.3,ra*1.3,N_ii));
C.pop     = 100; % scale with N_ii
C.scale   = 2.1; % visually adjust this as required
C.spacing = 1.1; 
C.alpha   = 2.331;
C.beta    = 2.2;
[I,disks] = createSubstrate(ra,N_ii,C,2);
save(sprintf("Results/Substr/Nii=%d.mat",N_ii),'I','disks','N_ii','ra');
%disks

%draw substrate
figure; [X,Y] = meshgrid(linspace(-ra*1.3,ra*1.3,N_ii)); subplot(1,3,1),pcolor(X,Y,I),axis image,shading interp,

%% sequence

gRes = 0.001; gSteps = gMax/gRes;
G=0*t; G(t<=delta)=1; G(t>=Delta&t<=Delta+delta)=-1;
dir=[1,0]; G=kron(dir,G');
seq.G = G; seq.t = t; seq.G_s = 0:gRes:gMax;
bVal = (gam^2 * seq.G_s.*seq.G_s * delta^2 * (Delta - delta/3));

%% simulation 

tic
simu.r = X(1,2)-X(1,1);
simu.N = N_rw;
simu.D = diffu;
simu.P = flip([perma; flip(perma)]);
S = diffSim(I,seq,simu,gam);
elapsedTime = toc;
save(sprintf('Results/Sim2/Nii=%d Nrw=1e%d Nt=1e%d',N_ii,log10(N_rw),log10(N_t))); % save                                                                                                                                                                                                                                                                                                                                                                                                 