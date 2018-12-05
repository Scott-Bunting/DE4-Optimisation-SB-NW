function [x, Fl, val] = main_function(md, l)

    %% Notes
    %Where applicable, I have used the same variable notation as described in
    %the function documentation. Where not applicable, or multiple variations
    %are required, the variable names have been changed but remain suitable and
    %are described by their respective comments.

    %% Initial point & Parameters

    x0 = [0.03,0.08,0.08,0.001,0.01];

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

    %Lower bounds
    lb = [0.02, 0.005, 0, 0.005, 0.005];

    %Ask whether the upper bound for this should be Infinite or it should be
    %limited in the bounds. It is inherently limited by the linear inequality.
    
    %Length from Subsystem 1 is included in variable 3.
    ub = [0.05, 0.01, l, 0.12, 0.05];

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

    %% Reading material properties

    filename = 'mat_ces.csv';

    %Import Material Properties as Table
    mat = readtable(filename);

    %Convert data to Struct format
    M = table2struct(mat);
    [m ] = size(M);

    %% Minimisation function

    %For loop to iterate through materials
    for t=1:m

        %Average Desnity and Stress of Material
        rho = ((M(t).Density_LB + M(t).Density_UB)/2);
        sig = ((M(t).YS_LB + M(t).YS_UB)/2)*10^6;

        %Creating instances of the Objective function and Constraint function
        confun = @(x)sysConstraintFunction(x, rho, sig, md); 
        fun = @(x)objectiveFunction(x, rho);

        %Executing Optimisation Function
        [x,fval,exitflag] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,confun);

        %Append the metrics from the Material
        M(t).Mass = fval;
        M(t).Cost = fval*(M(t).Price_LB + M(t).Price_UB)/2;
        M(t).Thrust = 2*n_r*n_b*(x(3)^2 - x(4)^2)*x(1)*sin(theta)*omega*rho_air*g;
        M(t).Stress = (md*g*(x(4)))/(n_r*n_b*pi*x(5)*x(2)^3);
        M(t).ExitFlag = exitflag;
        M(t).Vars = x;
    end

    %Outputting linking variables
    [val,idx] = min([M.Mass]);
    optim = M(idx).Vars;
    Fl = M(idx).Thrust;
    
    

    %% Print functions

    %Reporting out results of Optimisation
    for q=1:m
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
        disp(['Yield stress: ' num2str(((M(q).YS_LB + M(q).YS_UB)/2)*10^6)])
    end

    disp([" "])
    disp(["Optimal Material for Mass: " + M(idx).Name]);

    %% Plots

    %Plotting Cost against Mass
    figure(1);
    scatter([M.Cost], [M.Mass], 5, 'filled');
    title('Price vs. Mass Pareto');
    xlabel('Price (£)');
    ylabel('Mass (Kg)');
    
end