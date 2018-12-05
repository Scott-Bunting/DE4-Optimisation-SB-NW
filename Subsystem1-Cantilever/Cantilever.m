function [out, w] = Cantilever(Fl,mm,md,rpm,r)
%CANTILEVER This function optimises the dimensions of the cantilever
%% parameters
%Fl = 7.84;
%mm = 0.06;
%md = 1.4;
%r = 0.1867;
g = 9.8;
E = 164000000000;
ro = 1780;
k = 1.875;

sigmax = 2780000000;
defmax = 0.001;
fmin = 250;

%% optimisation
objective = @(x) (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*ro;

% initial guess
x0 = [0.1,0.1,0.005,1];

% variable bounds
lb = [0.005 0.005 0.001 r*1.05];
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
disp(['x1 (a) [m] = ' num2str(x(1))])
disp(['x2 (b) [m] = ' num2str(x(2))])
disp(['x3 (t) [m] = ' num2str(x(3))])
disp(['x4 (L) [m] = ' num2str(x(4))])
disp(['sigx [Pa] = ' num2str(c(1)+sigmax)])
disp(['sigy [Pa] = ' num2str(c(2)+sigmax)])
disp(['defx [m] = ' num2str(c(3)+defmax)])
disp(['f1nf [Hz] = ' num2str(-c(4)+fmin)])
out = x;
w = (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*ro;
end

