function f = objectiveFunction(x, rhoRotor)
        
    %% Objective function definition
    
    f = rhoRotor*pi*x(2)*(x(1)*x(3) + x(5)*x(4));

end
