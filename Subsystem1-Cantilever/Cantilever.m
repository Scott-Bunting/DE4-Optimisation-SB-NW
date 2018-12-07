function [out, w] = Cantilever(Fl,mm,md,rpm,r)
%CANTILEVER This function optimises the dimensions of the cantilever
%% parameters
% Fl = 7.84;
% mm = 0.06;
% md = 1.4;
% r = 0.1867;
g = 9.8;
E = 164000000000;
ro = 1780;
k = 1.875;

sigmax = 2780000000;
defmax = 0.001;
fmin = 350;

%% optimisation
objective = @(x) (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*ro;

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
nonlincon = @(x)nlcon1(x, Fl, mm, g, md, E, ro, k, sigmax, defmax, fmin);

% optimize with fmincon
%[X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] 
% = fmincon(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)
[x, fval, ef, output, lambda] = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon);

% show final objective
disp(['Final arm weight [kg]: ' num2str(objective(x))])

[c, ceq] = nlcon1(x, Fl, mm, g, md, E, ro, k, sigmax, defmax, fmin);

% print solution
disp('Solution')
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

if (c(1)+sigmax)>(sigmax*0.9)
    disp(['sigx [Pa] = ' num2str(c(1)+sigmax) ' << active'])
else
    disp(['sigx [Pa] = ' num2str(c(1)+sigmax) ' << inactive'])
end

%disp(['sigy [Pa] = ' num2str(c(2)+sigmax)])
if (c(1)+sigmax)>(sigmax*0.9)
    disp(['sigy [Pa] = ' num2str(c(2)+sigmax) ' << active'])
else
    disp(['sigy [Pa] = ' num2str(c(2)+sigmax) ' << inactive'])
end

%disp(['defx [m] = ' num2str(c(3)+defmax)])
if (c(3)+defmax)>(defmax*0.9)
    disp(['defx [m] = ' num2str(c(3)+defmax) ' << active'])
else
    disp(['defx [m] = ' num2str(c(3)+defmax) ' << inactive'])
end

%disp(['f1nf [Hz] = ' num2str(-c(4)+fmin)])
if (-c(4)+fmin)<(fmin*1.1)
    disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << active'])
else
    disp(['f1nf [Hz] = ' num2str(-c(4)+fmin) ' << inactive'])
end

%disp(['f2nf [Hz] = ' num2str(-c(5)+fmin)])
if (-c(5)+fmin)<(fmin*1.1)
    disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << active'])
else
    disp(['f2nf [Hz] = ' num2str(-c(5)+fmin) ' << inactive'])
end

out = x;
w = (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*ro;
end

