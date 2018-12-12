function f = objectiveFunction(x, rhoRotor)
    
    %% Paramaters for objective function
    
    numberRotors = 4;
    numberBlades = 2;
    
    %% Objective function definition
    
    f = numberRotors*numberBlades*rhoRotor*x(1)*(x(2)*(x(3)-x(4)) + x(5)*x(4));

end
