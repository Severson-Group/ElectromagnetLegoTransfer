clear;

%% System Stabilization - All Z units in cm

% Linearized, estimated parameters
Ks = 0.0028; % Sensor Gain
dfdz = -0.1159; % Change in force per change in Z (cm)
dfdi = 0.0422; % Change in force per amp
dTdz = 0.0028; %Change in T (field intensity vs z (in cm)

M = 0.0118; % Total Levitation mass (in Kg)


%% Unity feedback PD controller with damping = 1

% Kd calculated off of Kp values
Kp = 80;
Kd = sqrt((dfdi * Kp - dfdz)/M)*2*M/dfdi;

% Steady state z error 
e_ss_z = 1/(-dfdz/M + dfdi/M * Kp);

electromag_plant_tf = tf([dfdi/M] , [1 0 -dfdz/M]);
s = tf('s');
pd_controller_tf = Kp + Kd*s;

G = electromag_plant_tf*pd_controller_tf;

ClosedLoop_tf = G / (1 + G) ; 
figure();
step(ClosedLoop_tf) ; 
title(['Z Step Responce with Kp = ',num2str(Kp)]);


%% Unity feedback PID controller

% Kd calculated off of Kp values
Kp = 80;
Kd = 20;
Ki = 20;


electromag_plant_tf = tf([dfdi/M] , [1 0 -dfdz/M]);
s = tf('s');
pid_controller_tf = Kp + Kd*s + Ki/s;

G = electromag_plant_tf*pid_controller_tf;

ClosedLoop_tf = G / (1 + G) ; 
figure();
[z,t] = step(ClosedLoop_tf) ; 
plot(t,2.5*z);
title(['Z Step Responce with Kp = ',num2str(Kp)]);

%% Hall Effect Feedback

% Kd calculated off of Kp values
Kp = 80;
Kd = 20;
Ki = 20;


electromag_plant_tf = tf([dfdi/M] , [1 0 -dfdz/M]);
s = tf('s');
pid_controller_tf = Kp + Kd*s + Ki/s;

G = electromag_plant_tf*pid_controller_tf;

ClosedLoop_tf = G / (1 + G) ; 
figure();
[z,t] = step(ClosedLoop_tf) ; 
plot(t,2.5*z);
title(['Z Step Responce with Kp = ',num2str(Kp)]);
