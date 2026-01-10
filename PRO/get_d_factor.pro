PRO get_d_factor,IGBPgrid,longrid,latgrid,meanCosSZAgrid,d_grid,factorgrid
; will return, in 'factorgrid' the 'd' factor needed in (1+d)/(1+2*d*meanCosSZAgrid)
;
; translate the surface type index in IGBPgrid to a 'd' number
;   REAL, PARAMETER :: d ( nigbp) = &
;      (/ 0.40,  & ! ( 1) EVERGREEN NEEDLE FOR
;      0.44,  & ! ( 2) EVERGREEN BROAD FOR
;      0.32,  & ! ( 3) DECIDUOUS NEEDLE FOR
;      0.39,  & ! ( 4) DECIDUOUS BROAD FOR
;      0.22,  & ! ( 5) MIXED FOREST
;      0.28,  & ! ( 6) CLOSED SHRUBS
;      0.40,  & ! ( 7) OPEN/SHRUBS
;      0.15,  & ! ( 8) WOODY SAVANNA
;      0.27,  & ! ( 9) SAVANNA
;      0.22,  & ! (10) GRASSLAND
;      0.35,  & ! (11) WETLAND
;      0.24,  & ! (12) CROPLAND (CAGEX-APR)
;      0.10,  & ! (13) URBAN
;      0.12,  & ! (14) CROP MOSAIC
;      0.10,  & ! (15) ANTARCTIC SNOW
;      0.40,  & ! (16) BARREN/DESERT
;      0.41,  & ! (17) OCEAN WATER
;      0.58,  & ! (18) TUNDRA
;      0.10,  & ! (19) FRESH SNOW
;      0.10 /)  ! (20) SEA ICE
dvals=[911,0.4,0.44,0.32,0.39,0.22,0.28,0.4,0.15,0.27,0.22,0.35,0.24,0.1,0.12,0.1,0.4,0.41,0.58,0.1,0.1,-911]
d_grid=IGBPgrid*0.0+911
for i=1,20,1 do begin
idx=where(IGBPgrid eq i)
if (idx(0) ne -1) then d_grid(idx)=dvals(i)
endfor
if (where(abs(d_grid) eq 911) ne -1) then stop
factorgrid=(1.0+d_grid)/(1.0+2.0*d_grid*meanCosSZAgrid)
return
end

