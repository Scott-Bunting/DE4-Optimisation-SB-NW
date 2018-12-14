function [out, m, name] = CantileverMultiCrossSec(Fl,mm,md,rpm,d,defmax,rho,sigmax,E)
%CANTILEVER SUBSYSTEM This function optimises the dimensions of the
%cantilever with two cross-sections
%% Reading material properties
g = 9.8; %Gravitational acceleration
k = 1.875; %Rezonence mode shape coef
fmin = rpm/60*1.3; %Calculating the max operation frequency of motors
CrossSections = ["Rectanular cross-section", "Eliptic cross-section"];
Solutions = []; %Array for solutions (weight)
X = []; %Array for solutions (variables)

rng default %Making rnd reproducible

%Setting options for optimisation
options = optimoptions(@fmincon,'Algorithm', 'sqp','MaxFunctionEvaluations',5000);
gs = GlobalSearch;

%Objective functions for rectangular and elliptic cross-sections
objective = {@(x) (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*rho, ...
    @(x) (x(1)/2*x(2)/2*pi-((x(1)/2-x(3))*(x(2)/2-x(3))*pi))*x(4)*rho};

%Looping through the cross-sections
for i=1:2
    disp(' ');
    disp(CrossSections(i));

    %Initial guess
    x0 = [0.09,0.09,0.004,0.9];

    %Variable bounds
    lb = [0.005 0.005 0.001 d/2];
    ub = [0.1 0.1 0.005 1];

    %Linear constraints
    A = [-1,0,2,0; 0,-1,2,0; 10,0,0,-1; 0,10,0,-1];
    b = [0;0;0;0];
    Aeq = [];
    beq = [];

    %Nonlinear constraints
    nonlincon = @(x)nlconMCS(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin, i);

    tic %Sarting clock to measure optimization time
    %Running fmincon optimizer with global search to ensure that the result
    %is indeed a global min
    problem = createOptimProblem('fmincon','x0',x0,'objective',objective{i},...
    'nonlcon',nonlincon,'Aineq',A,'bineq',b,'lb',lb,'ub',ub,'options',options);
    [x,fval,ef] = run(gs,problem);
    toc %Stoping clock and displaying optimization time

    %Displaying initial and final objective
    disp(['Initial arm weight [kg]: ' num2str(objective{i}(x0))])
    disp(['Final arm weight [kg]: ' num2str(objective{i}(x))])
    
    %Calculating constrain function values at the min point
    [c, ~] = nlconMCS(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin,i);
    
    %Showing the exit flag
    disp(['exit flag = ' num2str(ef)])
    
    %Displaying information regarding bounds and constraint activity
    if (x(1))<(lb(1)*1.1)
        disp(['x1 (a) [m] = ' num2str(x(1)) ' << lb-hit'])
    elseif (x(1))>(ub(1)*0.9)
        disp(['x1 (a) [m] = ' num2str(x(1)) ' << ub-hit'])
    else
        disp(['x1 (a) [m] = ' num2str(x(1))])
    end

    if (x(2))<(lb(2)*1.1)
        disp(['x2 (b) [m] = ' num2str(x(2)) ' << lb-hit'])
    elseif (x(2))>(ub(2)*0.9)
        disp(['x2 (b) [m] = ' num2str(x(2)) ' << ub-hit'])
    else
        disp(['x2 (b) [m] = ' num2str(x(2))])   
    end

    if (x(3))<(lb(3)*1.1)
        disp(['x3 (t) [m] = ' num2str(x(3)) ' << lb-hit'])
    elseif (x(3))>(ub(3)*0.9)
        disp(['x3 (t) [m] = ' num2str(x(3)) ' << ub-hit'])
    else
        disp(['x3 (t) [m] = ' num2str(x(3))])
    end

    if (x(4))<(lb(4)*1.1)
        disp(['x4 (L) [m] = ' num2str(x(4)) ' << lb-hit'])
    elseif (x(4))>(ub(4)*0.9)
        disp(['x4 (L) [m] = ' num2str(x(4)) ' << ub-hit'])
    else
        disp(['x4 (L) [m] = ' num2str(x(4))])
    end
    
    if (c(1)+sigmax)>sigmax
        disp(['sigx [Pa] = ' num2str(c(1)+sigmax) ' << dissatisfied, limit: ' num2str(sigmax)])
    elseif (c(1)+sigmax)>(sigmax*0.9)
        disp(['sigx [Pa] = ' num2str(c(1)+sigmax) ' << active, limit: ' num2str(sigmax)])
    else
        disp(['sigx [Pa] = ' num2str(c(1)+sigmax) ' << inactive, limit: ' num2str(sigmax)])
    end
    
    if (c(2)+sigmax)>sigmax
        disp(['sigy [Pa] = ' num2str(c(2)+sigmax) ' << dissatisfied, limit: ' num2str(sigmax)])
    elseif (c(2)+sigmax)>(sigmax*0.9)
        disp(['sigy [Pa] = ' num2str(c(2)+sigmax) ' << active, limit: ' num2str(sigmax)])
    else
        disp(['sigy [Pa] = ' num2str(c(2)+sigmax) ' << inactive, limit: ' num2str(sigmax)])
    end

    if (c(3)+defmax)>defmax
        disp(['defx [m] = ' num2str(c(3)+defmax) ' << dissatisfied, limit: ' num2str(defmax)])
    elseif (c(3)+defmax)>(defmax*0.9)
        disp(['defx [m] = ' num2str(c(3)+defmax) ' << active, limit: ' num2str(defmax)])
    else
        disp(['defx [m] = ' num2str(c(3)+defmax) ' << inactive, limit: ' num2str(defmax)])
    end

    if (ceil(-c(4)+fmin))<fmin
        disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << dissatisfied, limit: ' num2str(fmin)])
    elseif (-c(4)+fmin)<(fmin*1.1)
        disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << active, limit: ' num2str(fmin)])
    else
        disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << inactive, limit: ' num2str(fmin)])
    end

    if (ceil(-c(5)+fmin))<fmin
        disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << dissatisfied, limit: ' num2str(fmin)])
    elseif (-c(5)+fmin)<(fmin*1.1)
        disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << active, limit: ' num2str(fmin)])
    else
        disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << inactive, limit: ' num2str(fmin)])
    end
    
    %Collecting results if the optimizer converged
    if ef > 0
        Solutions =[Solutions fval]; %Adding weight to array
        X = [X [x(1), x(2), x(3), x(4)]']; %Adding wariables to array
    else
        Solutions =[Solutions Inf];
        X = [X [Inf, Inf, Inf, Inf]'];
    end

    
end

%Returning minimum of the results
[m, j]= min(Solutions);
out = X(:,j);
name = CrossSections(j);
end

