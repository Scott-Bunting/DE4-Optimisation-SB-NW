close all
clear all

%% Notes
%Where applicable, I have used the same variable notation as described in
%the function documentation. Where not applicable, or multiple variations
%are required, the variable names have been changed but remain suitable and
%are described by their respective comments.

%% Initial point & Parameters

%Design Parameters
theta = 1.3; %Angle of Attack
omega = 1528; %Maximum angular velocity
rho_air = 1.225; %Density of Air
g = 9.81; %Acceleration due to Gravity
n_r = 4; %Number of rotors
n_b = 2; %Number of blades per rotor
m_d = 1.4; %Mass of Drone

%% Bounds
% Need rationale for all of these bounds. Whether that is due to
% manufacturing requirements or feasibility.

%Initial Point
x0 = [0.03,0.03,0.05,0.005,0.005];

%Lower bounds
lb = [0.0, 0.001, 0, 0.001, 0.00];

%Ask whether the upper bound for this should be Infinite or it should be
%limited in the bounds. It is inherently limited by the linear inequality.
ub = [0.05, 0.1, 0.12, 0.12, 0.05];

%% Semi-active Constraints

% Inequalities commented out as replaced by bounds.

A = [0 0 -1 1 0;
    -1 0 0 0 1];
b = [0;
    0];

%% Active constraints

% Equalities commented out as replaced by bounds.

Aeq = [];
beq = [];

%% Reading material properties

filename = 'mat_ces.csv';

%Import Material Properties as Table
mat = readtable(filename);

%Convert data to Struct format
M = table2struct(mat);
[m ] = size(M);

%% Minimisation function

rng default %for reproducibility

%Setting Options for Optimisation
options = optimoptions('fmincon','Display','iter','Algorithm','interior-point');
gs = GlobalSearch;

%Index for Material Table (Adapted from multi-material code)
t = 3;

%Average Density and Stress of Material
rho = ((M(t).Density_LB + M(t).Density_UB)/2);
sig = ((M(t).YS_LB + M(t).YS_UB)/2)*10^6;
E = ((M(t).YM_LB + M(t).YM_UB)/2)*10^9;

%Creating instances of the Objective function and Constraint function
confun = @(x)constraintFunction(x, rho, sig, E); 
fun = @(x)objectiveFunction(x, rho);

%Using createOptimProblem
problem = createOptimProblem('fmincon','x0',x0,'objective',fun,...
    'nonlcon',confun,'Aineq',A,'bineq',b,'lb',lb,'ub',ub,'options',options);

[x,fval,exitflag,output,solutions] = run(gs,problem);


%Executing Optimisation Function
%[x,fval,exitflag,output] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,confun,options);

%Append the metrics from the Material
M(t).Mass = fval;
M(t).Cost = fval*(M(t).Price_LB + M(t).Price_UB)/2;
M(t).Thrust = 2*n_r*n_b*(x(3)^2 - x(4)^2)*x(1)*sin(theta)*omega*rho_air*g;
M(t).Stress = (m_d*g*(x(4)))/(n_r*n_b*pi*x(5)*x(2)^3);
I = (pi/4)*(x(1)/2)*(x(2)/2)^3;
om = (M(t).Thrust)/x(4);
M(t).Deflection = ((om*x(3)^4)/(8*E*I));
M(t).ExitFlag = exitflag;
M(t).Vars = x;

%Finding index of struct with smallest mass
%[val,idx] = min([M.Mass]);

%% Print functions

%Reporting out results of Optimisation

q=1;
disp(['Material: ' M(q).Name])
disp(['Exit flag:' num2str(M(q).ExitFlag)])
disp(['Min. weight [Kg] = ' num2str(M(q).Mass)])
disp(['Price [£] = ' num2str(M(q).Cost)])
disp(['Width x(1) [m] = ' num2str(M(q).Vars(1))])
disp(['Thickness x(2) [m] = ' num2str(M(q).Vars(2))])
disp(['Length x(3) [m] = ' num2str(M(q).Vars(3))])
disp(['Length Root x(4) [m] = ' num2str(M(q).Vars(4))])
disp(['Width Root x(5) [m] = ' num2str(M(q).Vars(5))])
disp(['Thrust Generated: ' num2str(M(q).Thrust)])
disp(['Stress at root: ' num2str(M(q).Stress)])
disp(['Deflection: ' num2str(M(q).Deflection)])
disp(['Yield stress: ' num2str(((M(q).YS_LB + M(q).YS_UB)/2)*10^6)])

disp(output)


disp([" "])
%disp(["Optimal Material for Mass: " + M(idx).Name]);

%% Plots

%Plotting Cost against Mass
figure(1);
scatter([M.Cost], [M.Mass], 5, 'filled');
title('Price vs. Mass Pareto');
xlabel('Price (£)');
ylabel('Mass (Kg)');