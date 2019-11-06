function netZForce = Force(i,z)
    LevitationSystemGenerator(i,z);
    mi_analyze(1);
    mi_loadsolution;
    mo_groupselectblock(1); %select magnet
    force = mo_blockintegral(19) ; %weighted stress tensor
    magnetDensity = 7.5; %g/cm^3, should be able to get this from material prop later
    mo_seteditmode('contour');
    mo_groupselectblock(1); %select the magnet
    block_volume = mo_blockintegral(10) ; %volume in m^3
    payload = 10; %payload mass in grams
    magnet_mass = magnetDensity*(1/1000)*(100^3)*block_volume + payload/1000; %mass in kg
    netZForce = force - magnet_mass*9.8;
end
