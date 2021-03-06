close all
clear all

%% Notes

%Where applicable, I have used the same variable notation as described in
%the function documentation. Where not applicable, or multiple variations
%are required, the variable names have been changed but remain suitable and
%are described by their respective comments.

%% Parameters

tic

%Design Parameters
theta = 1.3; %Angle of attack
omega = 1528; %Maximum angular velocity
rho_air = 1.225; %Density of air
g = 9.81; %Acceleration due to gravity
n_r = 4; %Number of rotors
n_b = 2; %Number of blades per rotor
m_d = 1.4; %Mass of drone
PF = 2; %Power factor

%% Bounds and Initial Point

%Initial Point
x0 = [0.03,0.03,0.08,0.005,0.005];

%Lower Bounds
%lb = [0.001, 0.001, 0.001, 0.001, 0.001];
lb = [0, 0.002, 0, 0.005, 0.001];

%Upper Bounds
ub = [0.01, 0.01, 0.2, 0.2, 0.01];

%% Semi-active Constraints

A = [0 0 -1 1 0;
    -1 0 0 0 1];

A = [];

b = [0;
    0];

b = [];

%% Active constraints

% Equalities commented out as replaced by bounds.

Aeq = [];
beq = [];

%% Reading material properties

filename = 'mat_par.csv';

%Import Material Properties as Table
mat = readtable(filename);

%Convert data to Struct format
M = table2struct(mat);
[m ] = size(M);

%Selecting index, depending on material
%t = 1; %Index for Carbon Fibre
%t = input(prompt); %to accelerate testing

%% Optimisation

rng default %for reproducibility

%Initiating Global Search
gs = GlobalSearch;

%Setting the options for fmincon
algorithms = ["interior-point","sqp","sqp-legacy","active-set"...
    ,"trust-region-reflective"]; %exclude trust-region reflective
a = input('Algorithm  '); %to accelerate testing
algorithm = algorithms(a);
options = optimoptions('fmincon','Algorithm',algorithm);

for t=1:m
    %Average Density and Stress of Material
    rho = ((M(t).Density_LB + M(t).Density_UB)/2);
    sig = ((M(t).YS_LB + M(t).YS_UB)/2)*10^6;
    E = ((M(t).YM_LB + M(t).YM_UB)/2)*10^9;
    M(t).YM = E;
    
    tic
    %Creating instances of the Objective function and Constraint function
    confun = @(x)constraintFunctionEnd(x, rho, sig, E); 
    fun = @(x)objectiveFunctionEnd(x, rho);

    %Using createOptimProblem
    problem = createOptimProblem('fmincon','x0',x0,'objective',fun,...
    'nonlcon',confun,'Aineq',A,'bineq',b,'lb',lb,'ub',ub,'options',options);

    %[x,fval,exitflag,output] = fmincon(problem);
    [x,fval,exitflag,output,solutions] = run(gs,problem);
    fin = toc;
    %Executing Optimisation Function
    %[x,fval,exitflag,output] = fmincon(problem);

    %% Updating Struct with Optimal data

    %Cross-sectional area of root
    momentAreaNoLift = pi*(x(2)/2)*(x(5)/2)^3;
    
    %Safety factor for root strength
    safetyFactor = 1.5;

    %Thrust
    thrust = 2*sin(theta)*omega*rho_air*g*(x(3)^2 - x(4)^2)*x(1);
    
    %Stress at root (No Lift Area)
    sigmaRoot = ((safetyFactor*thrust*x(3)/2)/momentAreaNoLift)*(x(2)/2);

    %Append to the Structured Array
    M(t).Mass = fval;
    M(t).Cost = fval*(M(t).Price_LB + M(t).Price_UB)/2;
    M(t).Thrust = thrust;
    M(t).Stress = sigmaRoot;
    I = (pi/4)*(x(1)/2)*(x(2)/2)^3;
    disLoad = thrust/x(3);
    M(t).Deflection = (disLoad*x(3)^4)/(8*E*I);
    M(t).ExitFlag = exitflag;
    M(t).Vars = x;
    M(t).Time = fin;
end

%% Reporting Results

disp(output)

for t=1:m
    disp(' ')
    disp(['Material: ' M(t).Name])
    disp(['Exit flag:' num2str(M(t).ExitFlag)])
    disp(['Variables'])
    disp(['Width x(1) [m] = ' num2str(M(t).Vars(1))])
    disp(['Thickness x(2) [m] = ' num2str(M(t).Vars(2))])
    disp(['Length x(3) [m] = ' num2str(M(t).Vars(3))])
    disp(['Length Root x(4) [m] = ' num2str(M(t).Vars(4))])
    disp(['Width Root x(5) [m] = ' num2str(M(t).Vars(5))])
    disp(['Metrics'])
    disp(['Price [�] = ' num2str(M(t).Cost)])
    disp(['Mass [kg] = ' num2str(M(t).Mass)])
    disp(['Thrust Generated [N]: ' num2str(M(t).Thrust)])
    disp(['Stress at root [Pa]: ' num2str(M(t).Stress)])
    disp(['Yield Strength [Pa]: ' num2str(((M(t).YS_LB + M(t).YS_UB)/2)*10^6)])
    disp(['Deflection [m]: ' num2str(M(t).Deflection)])
    disp(['Time [s] :' num2str(M(t).Time)])
end

%Finding index of struct with smallest mass
[val,idx] = min([M.Mass]);
disp(' ')
disp(['Material: ' M(idx).Name])
disp(['Mass per rotor [kg]: ' num2str(M(idx).Mass)])
disp(['Price per rotor [�]: ' num2str(M(idx).Cost)])
disp(' ')
disp(['Total mass [kg]: ' num2str(8*M(idx).Mass)])
disp(['Total price [�]: ' num2str(8*M(idx).Cost)])
disp(['Time :' num2str(toc)])
figure(1);
scatter([M.Cost], [M.Mass], 5, 'filled');
title('Price vs. Mass Pareto');
xlabel('Price (�)');
ylabel('Mass (Kg)');

%% Objective Function

function f = objectiveFunctionEnd(x, rhoRotor)

    %% Objective function definition
    
    f = rhoRotor*pi*x(2)*(x(1)*x(3) + x(5)*x(4));

end

%% Non-linear constraint function
function [c,ceq] = constraintFunctionEnd(x, rhoMaterial, sigmaMaterial, E)

    %% Function input variables
    
    %{
    x = Design Variables
    rhoMaterial = Density of Material
    sigmaMaterial = Yield Stress of Material
    E = Youngs Modulus of Material
    %}

    %% Parameters for non-linear constraint
    
    numberRotors = 4; %No. of rotors
    numberBlades = 2; %No. of blades per rotor
    massDrone = 1.4; %Mass of drone
    g = 9.81; %Acceleration due to gravity
    rhoAir = 1.225; %Density of Air
    theta = 1.3; %Angle of Attack
    omega = 1528; %Maximum angular velocity
    powerFactor = 2; %Power factor
    safetyFactor = 1.5; %Safety factor
    
    %% Thrust Inequality
    %The minimum thrust generated must be greater than 2x (defined by the
    %Power factor) the force due to gravity on the drone.
    
    %Thrust generated by each rotor
    thrust = 2*sin(theta)*omega*rhoAir*g*(x(3)^2 - x(4)^2)*x(1);
    
    %Volume of components of rotor
    volLift = pi*x(1)*x(2)*(x(3)-x(4));
    volNoLift = pi*x(2)*x(5)*x(4);
    
    %Thrust Constraint (Including min. requirement and Mass of rotors)
    c1 = (powerFactor*massDrone*g)/(numberRotors*numberBlades)...
        - (thrust - rhoMaterial*g*(volLift + volNoLift));
    
    %% Root Stress Inequality
    %The stress at the root when fully loaded must be less than the yield
    %strength of the material of the rotor.
    
    %Cross-sectional area of root
    areaNoLift = pi*x(2)*x(5);
    momentAreaNoLift = pi*(x(2)/2)*(x(5)/2)^3;
    
    %Stress at root (No Lift Area)
    sigmaRoot = ((safetyFactor*thrust*x(3)/2)/momentAreaNoLift)*(x(2)/2);
    
    %Stress Constraint
    c2 = sigmaRoot - sigmaMaterial;
    
    %% Deflection Inequality
    %The deflection of a rotor blade must be smaller than 1mm. This is to
    %ensure that the lift equation remains true
    
    %This could be changed to a percentage of the length of the blade.
    
    %Second moment of area
    I = (pi/4)*(x(1)/2)*(x(2)/2)^3;
    
    %Distributed load
    omega = thrust/x(3);
    
    %Deflection Constraint
    c3 = (omega*x(3)^4)/(8*E*I) - 0.001;
    
    %% Concatenating the Constraints
    
    %When unbounded, the order of these constraints directly affects how
    %fmincon attempts to solve the problem
    
    c = [c1;c2;c3];
    
    %% Non-linear Constraints (Equalities)
    % Currently none. Deflection will probably end up being an equality
    % constraint as the deflection always tends to the limit set by the
    % inequality.
    
    ceq = 0; ...[c1;c3];
    
end
