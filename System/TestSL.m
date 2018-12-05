clear all

Fl = 7.84;
mm = 0.06;
m1 = 1;
mc = 0.5;
mr = 0.5;
rpm = 14000;
r = 0.1867;
l = 0.8;

md = m1 + mm + mc + mr;

for i = 1:3
    
    [x, mc] = Cantilever(Fl,mm,md,rpm,l);
    md = m1 + mm + mc + mr;
    l = x(4);
    [x, Fl, mr] = main_function(md, l);
    md = m1 + mm + mc + mr;
    l = x(3);

end