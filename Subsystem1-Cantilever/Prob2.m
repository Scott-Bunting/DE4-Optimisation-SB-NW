
%% parameters
Fl = 7.84;
mm = 0.06;
md = 1.4;
mr = 0.008;
g = 9.8;
E = 164000000000;
ro = 1780;
k = 1.875;
k2 = 4.694;
k3 = 7.855;

sigmax = 2780000000;
defmax = 0.001;
fmin = 250;

objective = @(x) (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3))))*x(4)*ro;

% initial guess
x0 = [0.1,0.1,0.005,1];

% variable bounds
lb = [0.005 0.005 0.001 0.1867]
ub = [0.1 0.1 0.005 1]

% show initial objective
disp(['Initial arm weight [kg]: ' num2str(objective(x0))])

% linear constraints
A = [];
b = [];
Aeq = [];
beq = [];

Fl =7.84;
% nonlinear constraints
nonlincon = @(x)nlcon1(x, Fl, mm, g, md, E, ro, k, sigmax, defmax, fmin);

% optimize with fmincon
%[X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] 
% = fmincon(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)
[x, fval, ef, output, lambda] = fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon);

% show final objective
disp(['Final arm weight [kg]: ' num2str(objective(x))])

[c, ceq] = nlcon1(x, Fl, mm, g, md, E, ro, k, sigmax, defmax, fmin)
% print solution
disp('Solution')
disp(['ef = ' num2str(ef)])
disp(['x1 (a) [m] = ' num2str(x(1))])
disp(['x2 (b) [m] = ' num2str(x(2))])
disp(['x3 (t) [m] = ' num2str(x(3))])
disp(['x4 (L) [m] = ' num2str(x(4))])
disp(['sigx [Pa] = ' num2str(((343*x(4)*x(2))/(25*((x(1)*x(2)^3)/6 - ((x(1) - 2*x(3))*(x(2) - 2*x(3))^3)/6))))])
disp(['sigy [Pa] = ' num2str(((343*x(4)*x(1))/(25*((x(1)^3*x(2))/6 - ((x(1) - 2*x(3))^3*(x(2) - 2*x(3)))/6))))])
disp(['defx [m] = ' num2str(((196*x(4)^3)/(25*(41000000000*x(1)*x(2)^3 - 41000000000*(x(1) - 2*x(3))*(x(2) - 2*x(3))^3))))])
disp(['f1nf [Hz] = ' num2str(c(4))])
disp(['f1 [Hz] = ' num2str(((140625*2^(1/2)*((12500000*x(1)^3*x(2) - 12500000*(x(1) - 2*x(3))^3*(x(2) - 2*x(3)))/(12500000*(1780*x(1)*x(2) - 1780*(x(1) - 2*x(3))*(x(2) - 2*x(3)))))^(1/2))/16))])
disp(['f2 [Hz] = ' num2str((6201917179951071*(((41000000000*x(1)^3*x(2))/3 - (41000000000*(x(1) - 2*x(3))^3*(x(2) - 2*x(3)))/3)/(1780*x(1)*x(2) - 1780*(x(1) - 2*x(3))*(x(2) - 2*x(3))))^(1/2))/281474976710656)])
disp(['f3 [Hz] = ' num2str((8683647287449303*(((41000000000*x(1)^3*x(2))/3 - (41000000000*(x(1) - 2*x(3))^3*(x(2) - 2*x(3)))/3)/(1780*x(1)*x(2) - 1780*(x(1) - 2*x(3))*(x(2) - 2*x(3))))^(1/2))/140737488355328)])