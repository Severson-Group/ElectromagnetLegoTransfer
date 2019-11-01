clear all;

%% Problem Def and Sweep Space

hallEffectSensorZ = -5; %Hall effect sensor position
linearizedZposn = 2.5;
linearizedCurrent = 2.65;

%Z posn in cm
magnetZMax = linearizedZposn + 1;
magnetZMin = linearizedZposn - 1;

%Min and Max Current
currentMax = linearizedCurrent + 1.;
currentMin = linearizedCurrent - 1;

payload = 10; %payload mass in grams


%% Sweep Electromag current while keeping Z posn constant

N = 100;
electromagnetCurrent = linspace(currentMin,currentMax,N);
fieldIntensity = [];
force_current = [];

index = 1 ;
for I = electromagnetCurrent
    LevitationSystemGenerator(I,linearizedZposn);
    mi_analyze(1);
    mi_loadsolution;   
    mo_groupselectblock(1); %select magnet
    force = mo_blockintegral(19) ; %weighted stress tensor
    force_current(index) = force;
    index = index + 1 ;
end

%figure();
%plot(electromagnetCurrent,force_current) ; 
%title("Force (N) vs Current (A)");
%figure();

magnetDensity = 7.5; %g/cm^3, should be able to get this from material prop later
mo_seteditmode('contour');
mo_groupselectblock(1); %select the magnet
block_volume = mo_blockintegral(10) ; %volume in m^3
magnet_mass = magnetDensity*(1/1000)*(100^3)*block_volume + payload/1000; %mass in kg
netForce_current = force_current - magnet_mass*9.8;
%plot(electromagnetCurrent,netForce_current) ; 
%title("Net Force (N) vs Current (A)");



%% Sweep Magnet Z keeping electromag current constant
magnetZ = linspace(magnetZMin,magnetZMax,N);
fieldIntensity = [];
zForce = [];
coilInductance = [];


index = 1 ;
for z = magnetZ
    LevitationSystemGenerator(linearizedCurrent,z);
    mi_analyze(1);
    mi_loadsolution;
    data = mo_getpointvalues(0,hallEffectSensorZ);
    fieldIntensity(index) = data(3);
    circuitProp = mo_getcircuitproperties('ElectromagnetCircuit');
    coilInductance(index) = circuitProp(3);
    
    mo_groupselectblock(1); %select magnet
    force = mo_blockintegral(19) ; %weighted stress tensor
    zForce(index) = force;
    index = index + 1 ;
end

plot(magnetZ,fieldIntensity) ;
title("Hall Effect Z Field Intensity (T) vs Z posn (cm)");
figure();
%plot(magnetZ,coilInductance) ; 
%title("Coil Inductance (H) vs Z posn (cm)");
%figure();
%plot(magnetZ,zForce) ; 
%title("Force (N) vs Z posn (cm)");
%figure();

magnetDensity = 7.5; %g/cm^3, should be able to get this from material prop later
mo_seteditmode('contour');
mo_groupselectblock(1); %select the magnet
block_volume = mo_blockintegral(10) ; %volume in m^3
magnet_mass = magnetDensity*(1/1000)*(100^3)*block_volume + payload/1000; %mass in kg
netZForce = zForce - magnet_mass*9.8;
%plot(magnetZ,netZForce) ; 
%title("Net Force (N) vs Z posn (cm)");

%% Linearization
derivativeEstimateIndex = 2;

%% Force/Current Linearization

linearizationPointIndex = N/2;
dfdi = (netForce_current(linearizationPointIndex+2)-netForce_current(linearizationPointIndex-2))/(electromagnetCurrent(linearizationPointIndex+2)-electromagnetCurrent(linearizationPointIndex-2));

F_linear = dfdi*(electromagnetCurrent - electromagnetCurrent(linearizationPointIndex)) + netForce_current(linearizationPointIndex) ; 

error_current = abs((F_linear-netForce_current)./netForce_current) ;
error_current = error_current*100;

figure();
plot(electromagnetCurrent,netForce_current) ; 
ylabel('Force (N)');
xlabel('Current (A)');
hold on;
plot(electromagnetCurrent,F_linear) ;
yyaxis right
plot(electromagnetCurrent,error_current) ;
ylabel('Error (%)');
title("Current Linearization with Payload of 10g");
hold off;

%% Force/Distance Linearization
linearizationPointIndex = N/2;
dfdz = (netZForce(linearizationPointIndex+2)-netZForce(linearizationPointIndex-2))/(magnetZ(linearizationPointIndex+2)-magnetZ(linearizationPointIndex-2));

Z_linear = dfdz*(magnetZ - magnetZ(linearizationPointIndex)) + netZForce(linearizationPointIndex) ; 

error_z = abs((Z_linear-netZForce)./netZForce) ;
error_z = error_z.*100;

figure();
plot(magnetZ,netZForce) ; 
ylabel('Force (N)');
xlabel('Posn (cm)');
hold on;
plot(magnetZ,Z_linear) ;
yyaxis right
plot(magnetZ,error_z) ;
ylabel('Linearization Error (%)');
title("Force/Position Linearization with Payload of 10g");
hold off;

%% B Field /Distance Linearization

linearizationPointIndex = N/2;
dTdz = (fieldIntensity(linearizationPointIndex+2)-fieldIntensity(linearizationPointIndex-2))/(magnetZ(linearizationPointIndex+2)-magnetZ(linearizationPointIndex-2));

B_linear = dTdz*(magnetZ - magnetZ(linearizationPointIndex)) + fieldIntensity(linearizationPointIndex) ; 

error_B = abs((B_linear-fieldIntensity)./fieldIntensity) ;
error_B = error_B.*100;

figure();
plot(magnetZ,fieldIntensity) ; 
ylabel('Field Intensity (T)');
xlabel('Posn (cm)');
hold on;
plot(magnetZ,B_linear) ;
yyaxis right
plot(magnetZ,error_B) ;
ylabel('Linearization Error (%)');
title("Field Intensity Linearization with Payload of 10g");
hold off;
