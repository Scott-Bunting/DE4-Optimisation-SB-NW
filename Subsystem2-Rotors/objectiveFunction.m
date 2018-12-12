function f = objectiveFunction(x, rhoRotor)
    
    %Parameters for mass
    numberRotors = 4;
    numberBlades = 2;
    g = 9.81;
    
    %mass function
    f = numberRotors*numberBlades*rhoRotor*x(1)*(x(2)*(x(3)-x(4)) + x(5)*x(4));

end
