clear

% parameters
Fl = 7.84;
mm = 0.06;
md = 1.4;
g = 9.8;
E = 164000000000;
ro = 1780;
k = 1.875;
k2 = 4.694;
k3 = 7.855;

%variables
syms a b t L

%intermediates
Ix = b^3*a/12-(b-2*t)^3*(a-2*t)/12;
Iy = a^3*b/12-(a-2*t)^3*(b-2*t)/12;

Ml = Fl * L;

Fm = mm * g
Mm = Fm * L

Fd = md * g
Md = Fd * L

sigxl = Ml*b/(2*Ix)
sigxd = Md*b/(2*Ix)
sigxm = Mm*b/(2*Ix)
sigyd = Md*a/(2*Iy)

delxl = Fl*L^3/(3*E*Ix)

fnf1 = k^2*sqrt(E*Iy/(ro*(a*b-(a-2*t)*(b-2*t))))
fnfk2 = k2^2*sqrt(E*Iy/(ro*(a*b-(a-2*t)*(b-2*t))))
fnfk3 = k3^2*sqrt(E*Iy/(ro*(a*b-(a-2*t)*(b-2*t))))
%fnf2 = 1/(2*pi)*sqrt(3*E*Iy/((0.2235*ro*L+mm)*L^3))

%pretty(simplify(fnf1))
