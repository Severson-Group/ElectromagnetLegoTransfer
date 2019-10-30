%% LEGO Stem Controller Simulation

% Mass of Sphere (kg)
Ms = 0.05;
g = 9.8;

% Magnetic force, distance and current estimator
% Estimate from DOI 10.17307
i_s = 3;
z_s = 0.01;
C = 0.04*g*(i_s^2/z_s^2) ;

C_z = 2*C*i_s^2 / (z_s)^3;
C_i = 2*C*i_s / (z_s)^2;

%% System Plant
G_p = tf(C_i/Ms,[1 0 C_z/Ms]);

%% Controller 
kd = 1;
kp = 1;
G_c = tf([kd kp]);
