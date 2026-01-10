;spawn,'setenv AST_DIR ~/idl_tools/www.boulder.swri.edu/~buie/idl/downloads/geteph/astdir/'
;spawn,'setenv NAIF_DIR ~/idl_tools/www.boulder.swri.edu/~buie/idl/downloads/geteph/naifdata/'
;spawn,'setenv LOC_DIR ~/idl_tools/www.boulder.swri.edu/~buie/idl/downloads/geteph/astfiles/'
jd=systime(/julian)
print,'1'
ephem,jd,568,21,'P301',ephemeris
print,'2'
ssgeom,ephemeris,sun,earth,phang
print,'3'
print,'Dist from E to S: ',sun
print,'Dist from E to M:',earth
end
