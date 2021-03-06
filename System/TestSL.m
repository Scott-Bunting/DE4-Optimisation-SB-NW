clear all

%% Notes

%What happens with poor initial guess
%What happens with the wrong algorithm
%How does convergence change with different algorithms?
%Vary bounds for Carbon Fibre to show that it will perform better 
%Derivative free approach
%Optimise for material and mass independently
%Intuition and research suggests that the initial materials are good
%If you extended with different materials it is to prove the initial
%material

Fl = 7.84;
mm = 0.06;
m1 = 1;
mc = 0.5;
mr = 0.5;
rpm = 14000;
r = 0.1867;
l = 0.5;
p_cfrp = 29.95;

md = m1 + mm + mc*4 + mr;
cost_c = 50;
cost_r = 50;

dc = 1;
dm = 1;
md2 = m1 + mm + mc + mr;

thrust_list = [];
price_list_r = [];
price_list_c = [];
mass_list_r = [];
mass_list_c = [];


while (dc > 0.01*10^-6 && dm > 0.001*10^-6)
    
    c1 = cost_c + cost_r;
    [x, mc] = CantileverSubSys(Fl,mm,md2,rpm,l,0.001,1550,800*10^6,110*10^9);
    mass_list_c = [mass_list_c mc];
    md1 = m1 + mm + mc + mr;
    cost_c = mc*p_cfrp;
    l = x(4);
    price_list_c = [price_list_c cost_c];
    
    [x, Fl, mr, cost_r] = Rotors_Sys(md1, sqrt(l/2));
    mass_list_r = [mass_list_r mr];
    thrust_list = [thrust_list Fl];
    price_list_r = [price_list_r cost_r];
    
    md2 = m1 + mm + mc + mr;
    l = 2*x(3);
    c2 = cost_c + cost_r;
    
    dm = md1 - md2; 
    dc = c1 - c2;
    
end

disp(' ')
disp('System')
disp('System Mass (kg):')
disp(mass_list_r + mass_list_c);
disp('System Cost (�):')
disp(price_list_r + price_list_c);
disp(' ')
disp('Cantilever')
disp('Cantilever Mass (kg):')
disp(mass_list_c)
disp('Cantilever Price (�):')
disp(price_list_c)
disp(' ')
disp('Rotor')
disp('Rotor Mass (kg):')
disp(mass_list_r)
disp('Rotor Price (�):')
disp(price_list_r)
disp('Rotor Thrust (N):')
disp(thrust_list)
disp(' ')
disp(['Mass Interval:' num2str(dm)])
disp(['Cost Interval:' num2str(dc)])
    