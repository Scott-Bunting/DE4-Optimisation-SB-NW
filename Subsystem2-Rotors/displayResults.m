function [] = displayResults(name, mass, cost, x_list, lift, stress, YS, exitflag)

disp([strcat('Material: ', name)])
disp(['Exit flag:' num2str(exitflag)])
disp(['Min. weight [Kg] = ' num2str(mass)])
disp(['Price [£] = ' num2str(cost)])
disp(['Width x(1) [m] = ' num2str(x_list(1))])
disp(['Thickness x(2) [m] = ' num2str(x_list(2))])
disp(['Length x(3) [m] = ' num2str(x_list(3))])
disp(['Length Root x(4) [m] = ' num2str(x_list(4))])
disp(['Width Root x(5) [m] = ' num2str(x_list(5))])
disp(['Lift Generated: ' num2str(lift)])
disp(['Stress at root: ' num2str(stress)])
disp(['Yield stress: ' num2str(YS*10^6)])

end
