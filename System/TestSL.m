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
l = 0.8;
p_cfrp = 29.95;

md = m1 + mm + mc + mr;
cost_c = 50;
cost_r = 50;

% for i = 1:3
%     
%     c1 = cost;
%     [x, mc] = Cantilever(Fl,mm,md,rpm,l);
%     md = m1 + mm + mc + mr;
%     l = x(4);
%     
%     [x, Fl, mr, cost, mass] = main_function(md, l);
%     md = m1 + mm + mc + mr;
%     l = x(3);
%     c2 = cost;
%     
%     dc = c1-c2;
%     
% 
% end

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
    [x, mc] = Cantilever(Fl,mm,md2,rpm,l);
    mass_list_c = [mass_list_c mc];
    md1 = m1 + mm + mc + mr;
    cost_c = mc*p_cfrp;
    l = x(4);
    price_list_c = [price_list_c cost_c];
    
    [x, Fl, mr, cost_r] = main_function(md1, l);
    mass_list_r = [mass_list_r mr];
    thrust_list = [thrust_list Fl];
    price_list_r = [price_list_r cost_r];
    
    md2 = m1 + mm + mc + mr;
    l = x(3);
    c2 = cost_c + cost_r;
    
    dm = md1 - md2; 
    dc = c1 - c2;
    
end

disp(' ')
disp('System')
disp('System Mass (kg):')
disp(mass_list_r + mass_list_c);
disp('System Cost (£):')
disp(price_list_r + price_list_c);
disp(' ')
disp('Cantilever')
disp('Cantilever Mass (kg):')
disp(mass_list_c)
disp('Cantilever Price (£):')
disp(price_list_c)
disp(' ')
disp('Rotor')
disp('Rotor Mass (kg):')
disp(mass_list_r)
disp('Rotor Price (£):')
disp(price_list_r)
disp('Rotor Thrust (N):')
disp(thrust_list)
disp(' ')
disp(['Mass Interval:' num2str(dm)])
disp(['Cost Interval:' num2str(dc)])
    