function [] = displayResults(mat_name,f,p,x_list,sig,exitflag)

%Parameters
n_r = 4; %No. of rotors
n_b = 2; %No. of blades per rotor
m_d = 1.4; %Mass of drone
rho_air = 1.225; %Density of Air
theta = 1.3; %Angle of Attack
omega = 1528; %Maximum angular velocity
g = 9.81; %Acceleration due to gravity

lift = 2*n_r*n_b*(x_list(3)^2 - x_list(4)^2)*x_list(1)*sin(theta)*omega*rho_air*g;
stress = (m_d*g*(x_list(4)))/(n_r*n_b*pi*x_list(5)*x_list(2)^3);

disp([strcat('Material: ', mat_name)])
disp(['Exit flag:' num2str(exitflag)])
disp(['Min. weight [Kg] = ' num2str(f)])
disp(['Price [$] = ' num2str(p)])
disp(['Width x(1) [m] = ' num2str(x_list(1))])
disp(['Thickness x(2) [m] = ' num2str(x_list(2))])
disp(['Length x(3) [m] = ' num2str(x_list(3))])
disp(['Length Root x(4) [m] = ' num2str(x_list(4))])
disp(['Width Root x(5) [m] = ' num2str(x_list(5))])
disp(['Lift Generated: ' num2str(lift)])
disp(['Stress at root: ' num2str(stress)])
disp(['Yield stress: ' num2str(sig*10^6)])

end
