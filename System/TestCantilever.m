clear all

Fl = 7.84;
mm = 0.06;
m1 = 0.1;
mc = 0.8;
mr = 0.5;
rpm = 14000;
r = 0.1867;
l = 0.5;
p_cfrp = 29.95;

md = m1 + mm + mc + mr;
%md = 1.5;

disp('|||||||||||||||||||||||||||||||||||||');
disp('-------------> START <---------------');
disp('|||||||||||||||||||||||||||||||||||||');

[x, mc, name] = CantileverMMGS(Fl,mm,md,rpm,l);

disp(['Lightest arm made of: ' name '  Weighting: ' num2str(mc)]);

% for i=1:5
%     disp(i);
%     [x, mc] = Cantilever(Fl,mm,md,rpm,l);
%     l = l-0.1;
% end