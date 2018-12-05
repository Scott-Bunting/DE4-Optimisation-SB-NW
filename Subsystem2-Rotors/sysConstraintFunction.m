function [c,ceq] = sysConstraintFunction(x, rho, sig, md)

    %Parameters for non-linear constraint
    
    n_r = 4; %No. of rotors
    n_b = 2; %No. of blades per rotor
    m_d = 1.4; %Mass of drone
    g = 9.81; %Acceleration due to gravity
    rho_air = 1.225; %Density of Air
    theta = 1.3; %Angle of Attack
    omega = 1528; %Maximum angular velocity
    Pf = 2; %Power factor
    FOS = 1.5; %Safety factor
    
    %Non-linear Thrust Equation
    c1 = (Pf*md*g)/n_r - 2*n_r*n_b*(x(3)^2 - x(4)^2)*x(1)*sin(theta)*omega*rho_air*g...
        + pi*rho*x(1)*n_r*n_b*(x(2)*(x(3) - x(4)) + x(5)*x(4));
    
    %sig is the yield stress of the material
    c2 = (FOS*md*g*(x(4)))/(n_r*n_b*pi*x(5)*x(2)^3) - sig;
    c = [c1;
        c2];
    %Nonlinear Stress constraints
    ceq = 0;
    
    
end
