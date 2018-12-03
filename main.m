close all
clear all

%% Notes
%Where applicable, I havve used the same variable notation as described in
%the function documentation. Where not applicable, or multiple variations
%are required, the variable names hae been changed but remain suitable and
%are described by their respective comments.

%% Initial point
x0 = [0.03,0.08,0.08,0.001,0.01];

%% Bounds
% Need rationale for all of these bounds. Whether that is due to
% manufacturing requirements or feasibility.

%Lower bounds
lb = [0.02, 0.005, 0, 0.005, 0.005];

%Ask whether the upper bound for this should be Infinite or it should be
%limited in the bounds. It is inherently limited by the linear inequality.
ub = [0.05, 0.01, 0.12, 0.12, 0.05];

%% Semi-active Constraints

% Inequalities commented out as replaced by bounds.
%{
%Algebraic expressions
A = [0 -1 0 0 0; %Semi-active
    0 0 0 0 -1 %Semi-active
    ];

%Constants
b = [-0.005; %Semi-active
    -0.005 %Semi-active
    ];
%} 

A = [0 0 -1 1 0;
    -1 0 0 0 1];
b = [0;
    0];

%% Active constraints

% Equalities commented out as replaced by bounds.
%{
%Algebraic expressions
Aeq = [-1 0 0 0 0; %Active
    0 0 0 -1 0 %Active
    ];

%Constants
beq = [-0.02; %Active
    -0.005 %Active
    ];
%}

Aeq = [];
beq = [];

%% Tables Indexes

%{

%1 = material name
%2 = material type
%3 = density lower bound (kg m-3)
%4 = density upper bound (kg m-3)
%5 = price lower bound (£ kg-1)
%6 = price upper bound (£ kg-1)
%7 = yield stress lower bound
%8 = yield stress upper bound
%9 = young's modulus lower bound
%10 = young's modulus upper bound
%}

%strings
name = 1;
type = 2;

%floats
%Subtract 2 when indexing due to these, as strings aren't included when
%reading data
d_lb = 3;
d_ub = 4;
p_lb = 5;
p_ub = 6;
ys_lb = 7;
ys_ub = 8;
ys_lb = 9;
ys_ub = 10;


%% Reading material properties

filename = 'mat_ces.csv';

%Import Material Properties as Table
mat = readtable(filename);

%Store material names in array
names = mat(:,1);
names = table2array(names)';

%Store material types in array
types = mat(:,2);
types = table2array(types)';

%Material Properties
data= csvread(filename,0,2);
[m,n] = size(data);

densities = (data(:,d_lb-2) + data(:,d_lb-2))/2; %Material Densities
costs = (data(:,p_lb-2) + data(:,p_ub-2))/2; %Material Costs per Kg
stresses = (data(:,ys_lb-2) + data(:,ys_lb-2))/2; %Yield Stresses of materials

%% Minimisation function

%Initialising lists for optimal solutions
x_mat = zeros(5,m);
f_list = zeros(1,m);
p_list = zeros(1,m);
exitflags = zeros(1,m);

%For loop to iterate through materials
for t=1:m
    
    d = densities(t); %Conversion to Kg/m^3
    sig = stresses(t)*10^6; %Conversion to MPa
    confun = @(x)constraintFunction(x, d, sig); 
    fun = @(x)objectiveFunction(x, d);
    
    [x,fval,exitflag,output] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,confun);
    f_list(t) = fval;
    x_mat(:,t) = x;
    p_list(t) = fval*costs(t);
    
    clear d
end

%% Print functions

%Reporting out results of optimisations
for q=1:m; disp_ans(names(q),f_list(q),p_list(q),x_mat(:,q),stresses(q),exitflags(q)); end

%Plotting cost against mass
figure(1);
scatter(p_list, f_list, 5, 'filled');
title('Price vs. Mass Pareto');
xlabel('Price ($)');
ylabel('Mass (Kg)');