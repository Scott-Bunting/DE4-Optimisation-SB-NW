function [x, Thrust, Mass, Cost] = main_function(md, l)

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

    %% Bounds
    % Need rationale for all of these bounds. Whether that is due to
    % manufacturing requirements or feasibility.
    
    %x(1): Width [m]
    x1_lb = 0.02;
    x1_in = 0.03;
    x1_ub = 0.05;
    
    %x(2): Thickness [m]
    x2_lb = 0.005;
    x2_in = 0.08;
    x2_un = 0.01;
    
    %x(3): Length [m]
    x3_lb = 0.005;
    x3_in = l;
    x3_ub = l;
    
    %x(4): Root Length [m]
    x4_lb = 0.005;
    x4_in = 0.001;
    x4_ub = l;
    
    %x(5): Root Width [m]
    x5_lb = 0.005;
    x5_in = 0.01;
    x5_ub = 0.05;

    %Lower bounds
    lb = [x1_lb, x2_lb, x3_lb, x4_lb, x5_lb];
    
    %Upper bounds
    ub = [x1_ub, x2_ub, x3_ub, x4_ub, x5_ub];
    
    %Initial point
    x0 = [x1_in, x2_in, x3_in, x4_in, x5_in];

    %% Semi-active Constraints

    %Linear Inequalities
    A = [0 0 -1 1 0;
        -1 0 0 0 1];
    b = [0;
        0];

    %% Active constraints

    %Linear Equalities
    Aeq = [];
    beq = [];

    %% Material properties

    filename = 'mat_ces.csv';

    %Import Material Properties as Table
    mat = readtable(filename);

    %Convert Table to Structured Array
    M = table2struct(mat);
    [m ] = size(M);

    %% Minimisation function

    %For loop to iterate through materials
    for t=1:m

        %Average Density of Material
        rho = ((M(t).Density_LB + M(t).Density_UB)/2);
        
        %Average Stress of Material
        sig = ((M(t).YS_LB + M(t).YS_UB)/2)*10^6;

        %Creating instances of the Objective function and Constraint function
        confun = @(x)sysConstraintFunction(x, rho, sig, md); 
        fun = @(x)objectiveFunction(x, rho);

        %Executing Optimisation Function
        disp(M(t).Name); %For debugging using fmincon stats
        [x,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,confun);

        %Append metrics to the Structured Array
        M(t).Mass = fval;
        M(t).Cost = fval*(M(t).Price_LB + M(t).Price_UB)/2;
        M(t).Thrust = 2*n_r*n_b*(x(3)^2 - x(4)^2)*x(1)*sin(theta)*omega*rho_air*g;
        M(t).Stress = (md*g*(x(4)))/(n_r*n_b*pi*x(5)*x(2)^3);
        M(t).ExitFlag = exitflag;
        M(t).Vars = x;
        
    end

    %Outputting linking variables
    [Mass,idx] = min([M.Mass]);
    Thrust = M(idx).Thrust;
    Cost = M(idx).Cost;
    
    %% Print functions

    %Reporting out results of Optimisation
    disp([" "])
    disp(["Optimal Material for Mass: " + M(idx).Name]);
    disp(['Min. weight [Kg] = ' num2str(M(idx).Mass)])
    disp(['Price [£] = ' num2str(M(idx).Cost)])
    disp(['Thrust Generated: ' num2str(M(idx).Thrust)])
    
    %% Plots

    %Plotting Cost against Mass
    figure(1);
    scatter([M.Cost], [M.Mass], 5, 'filled');
    title('Price vs. Mass');
    xlabel('Price (£)');
    ylabel('Mass (Kg)');
    
end