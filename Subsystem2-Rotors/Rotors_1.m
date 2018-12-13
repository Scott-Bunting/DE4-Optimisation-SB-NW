close all
clear all

%% Notes

%Where applicable, I have used the same variable notation as described in
%the function documentation. Where not applicable, or multiple variations
%are required, the variable names have been changed but remain suitable and
%are described by their respective comments.

%% Parameters

%Design Parameters
theta = 1.3; %Angle of Attack
omega = 1528; %Maximum angular velocity
rho_air = 1.225; %Density of Air
g = 9.81; %Acceleration due to Gravity
n_r = 4; %Number of rotors
n_b = 2; %Number of blades per rotor
m_d = 1.4; %Mass of Drone
PF = 2;

%% Bounds and Initial Point

%Initial Point
x0 = [0.03,0.03,0.08,0.005,0.005];

%Lower Bounds
lb = [0.001, 0.001, 0.001, 0.001, 0.001];

%The lower bounds are set at 1mm, as it is considered unreasonable for any
%of the Design Variables of a rotor blade to be smaller than this.

%Upper Bounds
ub = [0.05, 0.05, 0.5, 0.5, 0.05];

%The upper bounds have varying limits.
%The thickness is constrained to 20mm after comparison with blades on the
%market.
%The width is constrained to 50mm as this is within the diameter of the
%motor.
%The length is constrained to 500mm because any larger would make the drone
%too large for the application we have proposed.

%All of these need to be amended.

%% Semi-active Constraints

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

%Selecting index, depending on material
t = 1; %Index for Carbon Fibre

%% Optimisation

%Setting the options for fmincon
options = optimoptions('fmincon','Algorithm','interior-point');

%Average Density and Stress of Material
rho = ((M(t).Density_LB + M(t).Density_UB)/2);
sig = ((M(t).YS_LB + M(t).YS_UB)/2)*10^6;
E = ((M(t).YM_LB + M(t).YM_UB)/2)*10^9;

%Creating instances of the Objective function and Constraint function
confun = @(x)constraintFunction(x, rho, sig, E); 
fun = @(x)objectiveFunction(x, rho);

%Executing Optimisation Function
[x,fval,exitflag,output] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,confun,options);

%% Updating Struct with Optimal data

%Cross-sectional area of root
areaNoLift = pi*x(2)*x(5);

%Safety factor for root strength
FOS = 1.5;

%Thrust
thrust = 2*sin(theta)*omega*rho_air*g*(x(3)^2 - x(4)^2)*x(1);

%Stress at root
sigmaRoot = (thrust*x(3)/2)/areaNoLift;

%Append to the Structured Array
M(t).Mass = fval;
M(t).Cost = fval*(M(t).Price_LB + M(t).Price_UB)/2;
M(t).Thrust = n_r*n_b*thrust;
M(t).Stress = sigmaRoot;
I = (pi/4)*(x(1)/2)*(x(2)/2)^3;
disLoad = thrust/x(3);
M(t).Deflection = (disLoad*x(3)^4)/(8*E*I);
M(t).ExitFlag = exitflag;
M(t).Vars = x;

%% Reporting Results

q=t;
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

