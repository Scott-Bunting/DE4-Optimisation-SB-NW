clear all
%% Cantilever Subsystem stand-alone
%This script allows the cantilever substem to be evaluated independently
%from the rest of the system with predefined variables.

%Drone properties
Fl = 7.84; %Liftforce [N]
mm = 0.06; %Mass of one motor [kg]
mc = 0.5; %Mass of the cantilever [kg] (preliminary)
mr = 0.1; %Mass of one rotor [kg]
m1 = 0.1; %Mass of the rest of the drone [kg]
rpm = 14000; %RPM of motors
d = 0.5; %Diameter of rotors [m]
defmax = 0.001; %[m]

%Material properties
rho = 1550; %[kg/m^3]
sigmax = 800000000; %[Pa]
E = 110000000000; %[Pa]

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

disp('>> Analysis of bound and constraint activity <<');

%[x, mc, name] = CantileverMultiCrossSec(Fl,mm,md,rpm,d,defmax,rho,sigmax,E);

% for i=1:5
%     disp(i);
%     [x, mc] = Cantilever(Fl,mm,md,rpm,l);
%     l = l-0.1;
% end