function [c,ceq] = nlconMCS(x, Fl, mm, g, md, E, ro, k, sigmax, defmax, fmin, i)

Irx = (x(2)^3*x(1)-(x(2)-2*x(3))^3*(x(1)-2*x(3)))/12;
Iry = (x(1)^3*x(2)-(x(1)-2*x(3))^3*(x(2)-2*x(3)))/12;

Ix = [(x(2)^3*x(1)-(x(2)-2*x(3))^3*(x(1)-2*x(3)))/12,
    ((x(2)/2)^3*(x(1)/2)-((x(2)/2)-2*x(3))^3*((x(1)/2)-2*x(3)))*pi/4];
Iy = [(x(1)^3*x(2)-(x(1)-2*x(3))^3*(x(2)-2*x(3)))/12,
    ((x(1)/2)^3*(x(2)/2)-((x(1)/2)-2*x(3))^3*((x(2)/2)-2*x(3)))*pi/4];

Ml = Fl * x(4);

Fm = mm * g;
Mm = Fm * x(4);

Fd = md * g;
Md = Fd * x(4);

sigxl = Ml*x(2)/(2*Ix(i));
sigxd = Md*x(2)/(2*Ix(i));
sigxm = Mm*x(2)/(2*Ix(i));
sigyd = Md*x(1)/(2*Iy(i));

delxl = Fl*x(4)^3/(3*E*Ix(i));

fnf1 = (k^2)/(2*pi) * sqrt( (E*Iy(i)) / ((ro * (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3)))))*x(4)^4));
fnf2 = (k^2)/(2*pi) * sqrt( (E*Ix(i)) / ((ro * (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3)))))*x(4)^4));

c1 = -sigmax+sigxd;
c2 = -sigmax+sigyd;
c3 = -defmax+delxl;
c4 = +fmin-fnf1;
c5 = +fmin-fnf2;
c = [c1; c2; c3; c4; c5];
ceq = 0;

