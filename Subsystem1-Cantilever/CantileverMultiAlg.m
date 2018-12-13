function [t, name] = CantileverMultiAlg(Fl,mm,md,rpm,d,defmax,rho,sigmax,E)
%% Reading material properties
g = 9.8;
k = 1.875;
fmin = rpm/60*1.3;
Algorithms = ["interior-point"; "sqp"; "Active-set"];
Times = [];
Solutions = [];
Flags = [];

rng default %for reproducibility

% objective function elipse
objective = @(x) (x(1)/2*x(2)/2*pi-((x(1)/2-x(3))*(x(2)/2-x(3))*pi))*x(4)*rho;


for i=1:3 %Looping through the algorithms

    %Setting Options for Optimisation
    options = optimoptions('fmincon','Algorithm',Algorithms(i),'MaxFunctionEvaluations',3000);

    % initial guess
    x0 = [0.1,0.1,0.005,1];

    % variable bounds
    lb = [0.005 0.005 0.001 d/2];
    ub = [0.1 0.1 0.005 1];

    % linear constraints
    A = [-1,0,2,0; 0,-1,2,0; 10,0,0,-1; 0,10,0,-1];
    b = [0;0;0;0];
    Aeq = [];
    beq = [];

    % nonlinear constraints
    nonlincon = @(x)nlconMCS(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin, 2);

    tic
    [~, fval, ef] = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon, options);
    Times =  [Times; toc];
    Solutions = [Solutions; fval];
    Flags = [Flags; ef];
    
end

T = table(Algorithms,Flags,Solutions,Times)
[~ ,j]= min(Times);
t = Times(j);
name = Algorithms(j);
end

