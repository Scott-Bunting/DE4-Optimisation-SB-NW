clear all

Fl = 7.84;
mm = 0.06;
m1 = 1;
mc = 0.5
mr = 0.1
rpm = 14000;
r = 0.1867;
l = 1

md = m1 + mm + mc + mr

for i = 1:3
    [x, Fl, l, mr] = main_function(md, l);
    md = m1 + mm + mc + mr
    
    [x, mc] = Cantilever(Fl,mm,md,rpm,l);
    md = m1 + mm + mc + mr
end