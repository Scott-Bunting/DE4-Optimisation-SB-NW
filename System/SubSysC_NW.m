clear all
%% Cantilever Subsystem stand-alone
%This script allows the cantilever subsystem to be evaluated independently
%from the rest of the system with predefined variables.

%Parameters
Fl = 7.84; %Liftforce [N]
mm = 0.06; %Mass of one motor [kg]
mc = 0.3; %Mass of the cantilever [kg] (preliminary)
mr = 0.1; %Mass of one rotor [kg]
m1 = 0.1; %Mass of the rest of the drone [kg]
rpm = 14000; %RPM of motors
d = 0.5; %Diameter of rotors [m]
defmax = 0.001; %maximum defelction at the end of the arm [m]

%Material properties
sigmax = 800000000; %Yeild stress of cfrp [Pa]
rho = 1550; %Density of cfrp [kg/m^3]
E = 110000000000; %Young's modulus[Pa]

md = m1 + 4*(mm + mc + mr); %Estimated mass of drone

disp(' ');
disp('||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
disp('-------------> Cantilever Subsystem stand-alone <---------------');
disp('||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
disp(' ');

disp('>> Evaluation of rectangular and eliptic cross-sections <<');
disp(' ');

[x, mc, name] = CantileverMultiCrossSec(Fl,mm,md,rpm,d,defmax,rho,sigmax,E); 

disp(' ');
disp('Solution:');
disp(name);
disp(['Weight: [kg] ' num2str(mc)]);
disp(' ');

disp('>> Analysis of optimization algorithms <<');

[t, name] = CantileverMultiAlg(Fl,mm,md,rpm,d,defmax,rho,sigmax,E);

disp(' ');
disp('Fastest algoirthm:');
disp(name);
disp(['Time: [s] ' num2str(t)]);
disp(' ');

disp('>> Analysis of bound and linear constraint activity <<');

CantileverBoundTest(Fl,mm,md,rpm,d,defmax,rho,sigmax,E);