%% System Stabilization - All Z units in cm

% Linearized, estimated parameters
Ks = 0.0028; % Sensor Gain
dfdz = -0.1159; % Change in force per change in Z (cm)
dfdi = 0.0422; % Change in force per amp

M = 0.0118; % Total Levitation mass (in Kg)

Kp = -dfdz / (Ks*dfdi);
Kd = 1e03;

electromag_plant_tf = tf([dfdi/M] , [1 0 -dfdz/M]);
pd_controller_tf = tf([Kd Kp] ,[1]);

G = electromag_plant_tf*pd_controller_tf;

%rlocus(G);

ClosedLoop_tf = G / (1 + Ks*G) ; 

step(ClosedLoop_tf) ; 


