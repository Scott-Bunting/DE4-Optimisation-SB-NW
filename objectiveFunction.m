function f = objectiveFunction(x, Pr)
    
    %parameters for mass
    n_r = 4;
    n_b = 2;
    g = 9.81;
    %Pr = 1780;
    Pf = 2;
    
    %mass function
    f = n_r*n_b*Pr*x(1)*(x(2)*(x(3)-x(4)) + x(5)*x(4));

end