% Units g , cm 
function error = LevitationSystemGenerator(current,magnet_z)

%% Main System Parameters

% LEGO Block Size
LEGOUnitWidth = 4;
totalWidth = 4*0.8-0.02;
halfWidth = totalWidth/2;

% Outer wall width
wallWidth = 2e-1;

% 10mm Bolt (Core)
boltRadius = 5e-1;
boltHeight = 50e-1;
boltHeadRadius = 1.7/2;
boldHeadHeight = 0.617;
electroCoreMatType = '1006 Steel' ;

% Coil
electroCoilMatType = '24 AWG' ; 
wireRadius = 0.28067e-1; %24 Gauge Remington Industries Magnet Wire 
wireArea = pi*wireRadius^2;
wireOhmPerMeter = 80e-3;

fillFactor = 0.3; %Estimate with very bad fill factor
coilWidth = halfWidth - boltRadius - wallWidth;
coilArea = boltHeight*coilWidth;
maxTurns = floor(coilArea*fillFactor/wireArea);

coilWireLength = (boltRadius + coilWidth/2)*2*pi*maxTurns/100; % in meters
coilResistance = coilWireLength*wireOhmPerMeter;

% Magnet

magnetMaterialType = 'NdFeB 52 MGOe';
magnetHeight = 3e-1;
magnetRadius = 5e-1;

if (current < 0) 
   error = 1; 
   return;
end

%% Problem Globals

meshsize = .1;
automesh = 0;


%% Problem Definition

openfemm(1);

%Define progblem, open files

newdocument(0); % New electrostatics doc
%Not sure what the frequency param is, but it has to be 0
mi_probdef(0, 'centimeters','axi',1e-8,0,-30,0);

% Materials

mi_getmaterial('Air');
mi_getmaterial(electroCoreMatType);
mi_getmaterial(electroCoilMatType);
mi_getmaterial(magnetMaterialType);

%% Circuit for Electromagnet

circuitName = 'ElectromagnetCircuit';

mi_addcircprop(circuitName, current, 1);

%% Create Magnet - top is magnet_z below origin

%note - first param must be lower than first to draw arc right

magnetGroup = 1;

%Draw Core and Jacket
mi_drawpolygon([
    0,-magnet_z;
    magnetRadius,-magnet_z;
    magnetRadius,-magnet_z-magnetHeight;
    0,-magnet_z-magnetHeight;
]);

mi_addblocklabel(magnetRadius/2,-magnet_z-magnetHeight/2);
mi_selectlabel(magnetRadius/2,-magnet_z-magnetHeight/2) ;
mi_setblockprop(magnetMaterialType, automesh, meshsize, '', 90, magnetGroup,maxTurns);
mi_clearselected();


%% Create Electromagnet

core_group = 2;
coil_group = 3;

%Draw Core

mi_drawpolygon([0,0;
    boltRadius,0;
    boltRadius,boltHeight;
    boltHeadRadius,boltHeight;
    boltHeadRadius,boldHeadHeight+boltHeight;
    0,boldHeadHeight+boltHeight;
]);

mi_addblocklabel(boltRadius/2,boltHeight/2);
mi_selectlabel(boltRadius/2,boltHeight/2) ;
mi_setblockprop(electroCoreMatType, automesh, meshsize, '', 0, core_group,0); 
mi_clearselected();

%Draw Coils
mi_drawrectangle(boltRadius,0,coilWidth+boltRadius,boltHeight);
mi_addblocklabel(boltRadius+coilWidth/2,boltHeight/2);
mi_selectlabel(boltRadius+coilWidth/2,boltHeight/2) ;
mi_setblockprop(electroCoilMatType, automesh, meshsize, circuitName, 0, coil_group,maxTurns);
mi_clearselected();

%% Boundary Cond and Air

r = 7;  

mi_addblocklabel(totalWidth/2,magnet_z/2);
mi_selectlabel(totalWidth/2,magnet_z/2) ;
mi_setblockprop('Air', automesh, meshsize, '', 0, 0,0); 
mi_clearselected();

mi_drawarc(0,-r*2,0,r*2,180,5);
mi_drawline(0,-r*2,0,r*2);

mi_saveas('GeneratedProblem.FEM');

error = 0 ;

end