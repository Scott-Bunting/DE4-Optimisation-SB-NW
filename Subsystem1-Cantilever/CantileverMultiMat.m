function [out, m, name] = CantileverMultiMat(Fl,mm,md,rpm,r)
%CANTILEVER This function optimises the dimensions of the cantilever
%% Reading material properties
g = 9.8;
k = 1.875;
defmax = 0.001;
fmin = rpm/60*1.3;

disp('multimat');
filename = 'mat_ces.csv';

%Import Material Properties as Table
mat = readtable(filename);
%Convert data to Struct format
M = table2struct(mat);
[m] = size(M);

options = optimoptions(@fmincon,'Algorithm', 'sqp','MaxFunctionEvaluations',5000)

%For loop to iterate through materials
for i=1:1 %m

    %Average Desnity and Stress of Material
    rho = ((M(i).Density_LB + M(i).Density_UB)/2);
    sigmax = ((M(i).YS_LB + M(i).YS_UB)/2)*10^6;
    E = ((M(i).YM_LB + M(i).YM_UB)/2)*10^9;

    % objective function
    objective = @(x) (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*rho;

    % initial guess
    x0 = [0.1,0.1,0.005,1];

    % variable bounds
    lb = [0.005 0.005 0.001 r];
    ub = [0.1 0.1 0.005 1];

    % show initial objective
    disp(['Initial arm weight [kg]: ' num2str(objective(x0))])

    % linear constraints
    A = [];
    b = [];
    Aeq = [];
    beq = [];

    % nonlinear constraints
    nonlincon = @(x)nlcon1(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin);

    % optimize with fmincon
    %[X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] 
    % = fmincon(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)
    tic
    [x, fval, ef, output, lambda] = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon, options);
    toc
    % show final objective
    disp(M(i).Name)
    disp(['Final arm weight [kg]: ' num2str(objective(x))])

    [c, ceq] = nlcon1(x, Fl, mm, g, md, E, rho, k, sigmax, defmax, fmin);

    % print solution
    %disp('Solution')
    disp(['ef = ' num2str(ef)])

    %disp(['x1 (a) [m] = ' num2str(x(1))])
    if (x(1))<(lb(1)*1.1)
        disp(['x1 (a) [m] = ' num2str(x(1)) ' << lb-hit'])
    elseif (x(1))>(ub(1)*0.9)
        disp(['x1 (a) [m] = ' num2str(x(1)) ' << ub-hit'])
    else
        disp(['x1 (a) [m] = ' num2str(x(1))])
    end

    %disp(['x2 (b) [m] = ' num2str(x(2))])
    if (x(2))<(lb(2)*1.1)
        disp(['x2 (b) [m] = ' num2str(x(2)) ' << lb-hit'])
    elseif (x(2))>(ub(2)*0.9)
        disp(['x2 (b) [m] = ' num2str(x(2)) ' << ub-hit'])
    else
        disp(['x2 (b) [m] = ' num2str(x(2))])   
    end

    %disp(['x3 (t) [m] = ' num2str(x(3))])
    if (x(3))<(lb(3)*1.1)
        disp(['x3 (t) [m] = ' num2str(x(3)) ' << lb-hit'])
    elseif (x(3))>(ub(3)*0.9)
        disp(['x3 (t) [m] = ' num2str(x(3)) ' << ub-hit'])
    else
        disp(['x3 (t) [m] = ' num2str(x(3))])
    end

    %disp(['x4 (L) [m] = ' num2str(x(4))])
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

    if (-c(4)+fmin)<fmin
        disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << dissatisfied, limit: ' num2str(fmin)])
    elseif (-c(4)+fmin)<(fmin*1.1)
        disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << active, limit: ' num2str(fmin)])
    else
        disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << inactive, limit: ' num2str(fmin)])
    end

    if (-c(5)+fmin)<fmin
        disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << dissatisfied, limit: ' num2str(fmin)])
    elseif (-c(5)+fmin)<(fmin*1.1)
        disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << active, limit: ' num2str(fmin)])
    else
        disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << inactive, limit: ' num2str(fmin)])
    end
    
    if ef == 1
        M(i).Mass = fval;
        M(i).Cost = fval*(M(i).Price_LB + M(i).Price_UB)/2;
        M(i).x1 = x(1);
        M(i).x2 = x(2);
        M(i).x3 = x(3);
        M(i).x4 = x(4);
    else
        M(i).Mass = Inf;
        M(i).Cost = [];
        M(i).x1 = [];
        M(i).x2 = [];
        M(i).x3 = [];
        M(i).x4 = [];
    end

    
end
disp([M.Mass]);
[m, j]= min([M.Mass]);
out = [M(j).x1, M(j).x2, M(j).x3, M(j).x4];
name = M(j).Name;
end

