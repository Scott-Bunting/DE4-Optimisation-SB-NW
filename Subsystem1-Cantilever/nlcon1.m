function [c,ceq] = nlcon1(x, Fl, mm, g, md, E, ro, k, sigmax, defmax, fmin)

Ix = x(2)^3*x(1)/12-(x(2)-2*x(3))^3*(x(1)-2*x(3))/12;
Iy = x(1)^3*x(2)/12-(x(1)-2*x(3))^3*(x(2)-2*x(3))/12;

Ml = Fl * x(4);

Fm = mm * g;
Mm = Fm * x(4);

Fd = md * g;
Md = Fd * x(4);

sigxl = Ml*x(2)/(2*Ix);
sigxd = Md*x(2)/(2*Ix);
sigxm = Mm*x(2)/(2*Ix);
sigyd = Md*x(1)/(2*Iy);

delxl = Fl*x(4)^3/(3*E*Ix);

%fnf1 = k^2*sqrt(E*Iy/(ro*(x(1)*x(2)-(x(1)-2*x(3))*(x(2)-2*x(3)))));
fnf1 = (k^2)/(2*pi) * sqrt( (E*Iy) / ((ro * (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3)))))*x(4)^4));
%fnf2 = k^2*sqrt(E*Ix/(ro*(x(1)*x(2)-(x(1)-2*x(3))*(x(2)-2*x(3)))));
fnf2 = (k^2)/(2*pi) * sqrt( (E*Ix) / ((ro * (x(1)*x(2)-((x(1)-2*x(3))*(x(2)-2*x(3)))))*x(4)^4));

c1 = -sigmax+sigxd;
c2 = -sigmax+sigyd;
c3 = -defmax+delxl;
c4 = +fmin-fnf1;
c5 = +fmin-fnf2;
%c4 = -1+((3583850712014161875*6^(1/2)*((37500000*x(1)^3*x(2) - 37500000*(x(1) - 2*x(3))^3*(x(2) - 2*x(3)))/(37500000*x(4)^3*((39783*x(4))/100 + 3/50)))^(1/2))/9007199254740992);
c = [c1; c2; c3; c4; c5];
ceq = 0;

