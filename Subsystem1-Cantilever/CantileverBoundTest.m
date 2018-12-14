function [] = CantileverBoundTest(Fl,mm,md,rpm,d,defmax,rho,sigmax,E)
%CANTILEVER SUBSYSTEM This function tests the importance of bounds and
%linear constraints
%% Reading material properties
g = 9.8; %Gravitational acceleration
k = 1.875; %Rezonence mode shape coef
fmin = rpm/60*1.3; %Calculating the max operation frequency of motors

rng default %for reproducibility

%Objective function of elliptic cross-section
objective = @(x) (x(1)/2*x(2)/2*pi-((x(1)/2-x(3))*(x(2)/2-x(3))*pi))*x(4)*rho;


for i=1:3 %Looping through the options regarding bounds and linear constraints

    %Setting options for optimisation
    options = optimoptions('fmincon','Algorithm','sqp','MaxFunctionEvaluations',3000);

    %Initial guess
    x0 = [0.1,0.1,0.005,1];
    
    %Bounds are off in the first two cases and on for the final run
    if i<3
        disp(' ');
        disp(' ');
        disp('variable bounds OFF');
        lb = [0 0 0 0];
        ub = [Inf Inf Inf Inf];
    else
        disp(' ');
        disp(' ');
        disp('variable bounds ON');
        lb = [0.005 0.005 0.001 d/2];
        ub = [0.1 0.1 0.005 1];
    end
    
    %Linear constraints are off for the initial run and on afterwards
    if i<2
        disp('linear constraints OFF');
        A = [];
        b = [];
        Aeq = [];
        beq = [];
    else
        disp('linear constraints ON');
        A = [-1,0,2,0; 0,-1,2,0; 10,0,0,-1; 0,10,0,-1];
        b = [0;0;0;0];
        Aeq = [];
        beq = [];
    end

    %Nonlinear constraints
    nonlincon = @(x)nlconMCS(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin, 2);
    
    %Running fmincon optimizer
    [x, ~, ef] = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon, options);
    
    %Displaying final objective
    disp(['Final arm weight [kg]: ' num2str(objective(x))])
    
    %Calculating constrain function values at the min point
    [c, ~] = nlcon1(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin);
    
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
end

end

