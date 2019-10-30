%Find the equilibrium point using newton's method (easy and
%expensive,whatever)

function current = EQPointSolver(magnet_z,error_margin) 

current = 5; % initial guess
deltaCurrent = 0.0001;

forceArray = [];

% generate initial problem
error = LevitationSystemGenerator(current,sphere_z);

if (error ~= 0)
    return 
end

force = ForceSolver(1) ;

%try to approx using newtons method 
%%x_n+1 = x_n - f(x_n) / f '(x_n)
while (abs(force) > error_margin) 
    
  LevitationSystemGenerator(current+deltaCurrent,sphere_z) ;
  fPrime = (ForceSolver(1) - force)/deltaCurrent ; 
  forceArray = [forceArray force];
  
  LevitationSystemGenerator(current,sphere_z);
  force = ForceSolver(1) ;  
  
  current = current - force  / fPrime ; 
    
end 



end