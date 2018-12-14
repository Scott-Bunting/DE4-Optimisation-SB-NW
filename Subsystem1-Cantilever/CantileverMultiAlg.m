function [t, name] = CantileverMultiAlg(Fl,mm,md,rpm,d,defmax,rho,sigmax,E)
%CANTILEVER SUBSYSTEM This function tests and evaluates optimization
%algorithms 
%% Reading material properties
g = 9.8; %Gravitational acceleration
k = 1.875; %Rezonence mode shape coef
fmin = rpm/60*1.3; %Calculating the max operation frequency of motors
Algorithms = ["interior-point"; "sqp"; "Active-set"; "ga"];
Solutions = []; %Array for solutions (weight)
Times = []; %Array for the durations of the optimizations
Flags = []; %Array for flags

rng default %for reproducibility

%Objective function of elliptic cross-section
objective = @(x) (x(1)/2*x(2)/2*pi-((x(1)/2-x(3))*(x(2)/2-x(3))*pi))*x(4)*rho;

for i=1:3 %Looping through the algorithms

    %Setting options for optimisation (gradient based methods)
    options = optimoptions('fmincon','Algorithm',Algorithms(i),'MaxFunctionEvaluations',3000);

    %Initial guess
    x0 = [0.1,0.1,0.005,1];

    %Cariable bounds
    lb = [0.005 0.005 0.001 d/2];
    ub = [0.1 0.1 0.005 1];

    %Linear constraints
    A = [-1,0,2,0; 0,-1,2,0; 10,0,0,-1; 0,10,0,-1];
    b = [0;0;0;0];
    Aeq = [];
    beq = [];

    %Nonlinear constraints
    nonlincon = @(x)nlconMCS(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin, 2);

    tic %Sarting clock to measure optimization time
    %Running fmincon optimizer
    [~, fval, ef] = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon,options);
    Times =  [Times; toc]; %Stoping clock and adding value to array
    Solutions = [Solutions; fval]; %Adding final weight to array
    Flags = [Flags; ef]; %Adding exit flag to array
    
end

%Setting options for optimisation (genetic algorithm)
opts = optimoptions(@ga,'PopulationSize', 25,'MaxGenerations', 200,...
                    'EliteCount', 4,'FunctionTolerance', 1e-10,'Display','iter');
                
tic %Sarting clock to measure optimization time
%Running ga optimizer
[~, fbest, ef] = ga(objective, 4, [], [], [], [], lb, ub, nonlincon, [], opts);
Times =  [Times; toc]; %Stoping clock and adding value to array
Solutions = [Solutions; fbest]; %Adding final weight to array
Flags = [Flags; ef]; %Adding exit flag to array

%Putting all results into a table and dispalying it
T = table(Algorithms,Flags,Solutions,Times)

%Returning minimum of the results
[~ ,j]= min(Times);
t = Times(j);
name = Algorithms(j);
end

