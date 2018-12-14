close all
clear all

%% Notes

%Where applicable, I have used the same variable notation as described in
%the function documentation. Where not applicable, or multiple variations
%are required, the variable names have been changed but remain suitable and
%are described by their respective comments.

%% Parameters

%Universal Parameters
rhoAir = 1.225; %Density of air
g = 9.81; %Acceleration due to gravity

%Drone Design Parameters
massDrone = 1.4; %Mass of drone
numberRotors = 4; %No. of rotors
numberBlades = 2; %No. of blades per rotor
theta = 1.3; %Angle of attack
omega = 1528; %Maximum angular velocity

%Safety Factors
powerFactor = 2; %Power factor
safetyFactor = 1.5; %Safety factor

%% Bounds and Initial Point

%Initial Point
x0 = [0.03,0.03,0.08,0.005,0.005];

%Lower Bounds
%x(2) originally set to 0.005 and then amended after constraints analysis
%Length of root now 10mm
lb = [0, 0.002, 0, 0.01, 0.001];

%Upper Bounds
ub = [0.01, 0.01, 0.2, 0.2, 0.01];

%% Semi-active Constraints

A = [-1 0 0 0 1]; %[0 0 -1 1 0;

%Constrains the width of the root to be 2mm smaller than the width of the
%blade

b = -0.005;

%% Active constraints


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
%t = 1; %Index for Carbon Fibre
t = input('Material Index '); %to accelerate testing

%% Optimisation

%Start Timing
tic

%Setting up Random Number Generator
rng default %for reproducibility

%Initiating Global Search
gs = GlobalSearch;

%Setting the options for fmincon
algorithms = ["interior-point","sqp","sqp-legacy","active-set"];

%a = input('Algorithm '); %to accelerate testing
algorithm = algorithms(2);
options = optimoptions('fmincon','Algorithm',algorithm);

%Material Properties
rhoMaterial = ((M(t).Density_LB + M(t).Density_UB)/2); %Density
sigmaMaterial = ((M(t).YS_LB + M(t).YS_UB)/2)*10^6; %Yield Strength
EMaterial = ((M(t).YM_LB + M(t).YM_UB)/2)*10^9; %Young's Modulus
priceMaterial = (M(t).Price_LB + M(t).Price_UB)/2; %Price per kg

%Creating instances of the Objective function and Constraint function
confun = @(x)constraintFunctionEnd(x, rhoMaterial, sigmaMaterial, EMaterial); 
fun = @(x)objectiveFunctionEnd(x, rhoMaterial);

%Using createOptimProblem
problem = createOptimProblem('fmincon','x0',x0,'objective',fun,...
    'nonlcon',confun,'Aineq',A,'bineq',b,'lb',lb,'ub',ub,'options',options);

%Executing Optimisation Function with GlobalSearch
[x,fval,exitflag,output,solutions] = run(gs,problem);

%Executing Optimisation Function without GlobalSearch
%[x,fval,exitflag,output] = fmincon(problem);

%Stop Timing
fin = toc;

%% Updating Struct with Optimal data

%Moment of Inertia for Bending Stress
momentAreaNoLift = (pi/4)*(x(2)/2)*(x(5)/2)^3;

%Thrust and Load Calculation
thrust = 2*sin(theta)*omega*rhoAir*g*(x(3)^2 - x(4)^2)*x(1);
disLoad = thrust/x(3);

%Distance from Neutral Axis
y = (x(2)/2);

%Stress at root (No Lift Area)
sigmaRoot = ((safetyFactor*thrust*x(3)/2)/momentAreaNoLift)*y;

%Maximum Deflection
deflectionRotor = (disLoad*x(3)^4)/(8*EMaterial*momentAreaNoLift);

%Append to the Structured Array
M(t).Mass = fval;
M(t).Cost = fval*priceMaterial;
M(t).Thrust = thrust;
M(t).Stress = sigmaRoot;
M(t).Deflection = deflectionRotor;
M(t).ExitFlag = exitflag;
M(t).Vars = x;
M(t).Time = fin;

%% Reporting Results

disp(output)

q=t;
disp(['Material: ' M(q).Name])
disp('------')
disp(['Variables'])
disp('------')
disp(['Width x(1) [m] = ' num2str(M(q).Vars(1))])
disp(['Thickness x(2) [m] = ' num2str(M(q).Vars(2))])
disp(['Length x(3) [m] = ' num2str(M(q).Vars(3))])
disp(['Length Root x(4) [m] = ' num2str(M(q).Vars(4))])
disp(['Width Root x(5) [m] = ' num2str(M(q).Vars(5))])
disp('------')
disp(['Metrics'])
disp('------')
disp(['Price [£] = ' num2str(M(q).Cost)])
disp(['Mass [kg] = ' num2str(M(q).Mass)])
disp(['Thrust Generated [N]: ' num2str(M(q).Thrust)])
disp(['Stress at root [Pa]: ' num2str(M(q).Stress)])
disp(['Yield Strength [Pa]: ' num2str(((M(q).YS_LB + M(q).YS_UB)/2)*10^6)])
disp(['Deflection [m]: ' num2str(M(q).Deflection)])
disp('------')
disp(['Algorithm & Performance'])
disp('------')
disp(['Algorithm: ' + algorithm])
disp(['Exit flag: ' num2str(M(q).ExitFlag)])
disp(['Time elapsed: ' num2str(M(q).Time)])

%% Objective Function

function f = objectiveFunctionEnd(x, rhoRotor)

    %% Objective function definition
    
    f = rhoRotor*pi*x(2)*(x(1)*x(3) + x(5)*x(4));

end

%% Non-linear constraint function
function [c,ceq] = constraintFunctionEnd(x, rhoMaterial, sigmaMaterial, EMaterial)

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
    %Power factor) the weight of the drone.
    
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
    momentAreaNoLift = (pi/4)*(x(2)/2)*(x(5)/2)^3;
    
    %Stress at root (No Lift Area)
    sigmaRoot = ((safetyFactor*thrust*x(3)/2)/momentAreaNoLift)*(x(2)/2);
    
    %Stress Constraint
    c2 = sigmaRoot - sigmaMaterial;
    
    %% Deflection Inequality
    %The deflection of a rotor blade must be smaller than 1mm. This is to
    %ensure that the lift equation remains true
    
    %This could be changed to a percentage of the length of the blade.
    
    %Distributed load
    disLoad = thrust/x(3);
    
    %Deflection Constraint
    c3 = (disLoad*x(3)^4)/(8*EMaterial*momentAreaNoLift) - 0.001;
    
    %% Concatenating the Constraints
    
    %When unbounded, the order of these constraints directly affects how
    %fmincon attempts to solve the problem
    
    c = [c2;c3];
    
    %% Non-linear Constraints (Equalities)
    %Thrust is an equality for these bounds
    
    ceq = c1;
    
end