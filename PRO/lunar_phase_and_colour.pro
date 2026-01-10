










;------------------------------------------------
; Code to measure lunar reddening vs. phase
;------------------------------------------------
; 


Bstack=readfits('/data/pth/CUBES/cube_MkIII_onealfa_2456104.8348311_B_.fits',hB)
Vstack=readfits('/data/pth/CUBES/cube_MkIII_onealfa_2456104.8369029_V_.fits',hV)
getEXPOSURE,hB,Bexposuretime
getEXPOSURE,hV,Vexposuretime
B=reform(Bstack(*,*,0))
end
