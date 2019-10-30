function force = ForceSolver(gravity, payload)

mi_analyze(0);
mi_loadsolution;
mo_groupselectblock(1);
force = mo_blockintegral(19) ; %weighted stress tensor

if (gravity ~= 0) 
    mi_analyze(0);
    mi_loadsolution;

    magnetDensity = 7.5; %g/cm^3, should be able to get this from material prop later

    mo_seteditmode('contour');
    mo_groupselectblock(1); %select the magnet (== block#1)
    block_volume = mo_blockintegral(10) ; %volume in m^3

    ball_mass = magnetDensity*(1/1000)*(100^3)*block_volume + payload/1000; %mass in kg

    force = force - ball_mass*9.8;
end

end