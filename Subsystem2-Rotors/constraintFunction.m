function [c,ceq] = constraintFunction(x, rho, sig)

    %Input variables
    %{
    x = Design Variables
    rho = Density of Material
    sig = Yield Stress of Material
    %}

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
    
    %% Non-linear Constraints (Inequalities)
    
    %Thrust
    c1 = (Pf*m_d*g)/n_r - 2*n_r*n_b*(x(3)^2 - x(4)^2)*x(1)*sin(theta)*omega*rho_air*g...
        + pi*rho*x(1)*n_r*n_b*(x(2)*(x(3) - x(4)) + x(5)*x(4));
    
    %Root Stress
    c2 = (FOS*m_d*g*(x(4)))/(n_r*n_b*pi*x(5)*x(2)^3) - sig;
    
    %Concatenating the Constraints
    c = [c1;
        c2];
    
    %Deflection - to be completed
    
    %% Non-linear Constraints (Equalities)
    % Currently none - need to check activity
    ceq = 0;
    
    
end
