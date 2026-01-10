

;===============================================================================
;
; VALIDATION OF THE ESHINE SIMULATION SOFTWARE
;
; Compute the analytical solutions to:
;
; - the light from a sphere with a uniform Lambertian surface
; - the light from a sphere with a uniform Lommel-Seeliger surface
;
; It is assumed that the sphere is viewed from so far away that we receive
; radiation from half the sphere's surface (i.e. it can be regarded a point
; source).
;
;
; Version 2009-05-10
;
;===============================================================================




FUNCTION phase_function, phase_deg, surftype

phase_rad = phase_deg*!DPI/180.0d

if strcmp(surftype,'Lambert',/FOLD_CASE) then begin
  f = ((!DPI-abs(phase_rad))*cos(phase_rad) + sin(abs(phase_rad)))/!DPI
endif else if strcmp(surftype,'Lommel-Seeliger',/FOLD_CASE) then begin
  f = (1.0-sin(abs(phase_rad)/2)*tan(abs(phase_rad)/2)*alog(1.0/tan(abs(phase_rad)/4)))
endif else begin
  f = -1.0d
endelse

return, f

END



;-----------------------------------------------------------------------
; Constants
;-----------------------------------------------------------------------
Isun   = 1367.0     ; solar irradiance falling on Earth and Moon[W/m^2]
Dem    = 384400.0   ; Earth-Moon distance [km]
Rearth = 6365.0     ; Earth's radius [km]
Rmoon  = 1737.0     ; Moon's radius [km]


;-----------------------------------------------------------------------
; Compute the integrated earthshine (in W/m^2) as viewed from the Moon.
;-----------------------------------------------------------------------

; Earth's radius [meter]
R = Rearth*1000.0

; surface type
surftype = ['Lambert','Lommel-Seeliger']

; Bond albedo
A = 0.30

; radiance from the sphere
I = dblarr(2,361)

for ii=0,1 do begin

  ; single-scattering albedo
  if strcmp(surftype[ii],'Lambert',/FOLD_CASE) then begin
    omega0 = A
  endif else if strcmp(surftype[ii],'Lommel-Seeliger',/FOLD_CASE) then begin
    omega0 = 3.0*A/2.0/(1.0-alog(2.0))
  endif

  ; geometric albedo for a uniform sphere
  if strcmp(surftype[ii],'Lambert',/FOLD_CASE) then begin
    p = 2.0*omega0/3.0
  endif else if strcmp(surftype[ii],'Lommel-Seeliger',/FOLD_CASE) then begin
    p = omega0/8.0
  endif

  ; radiance from the sphere at zero phase angle (in W/sterad)
  I0 = p*R^2*Isun

  ; radiance from the sphere at all phase angles (in W/sterad)
  phase = fltarr(361)
  jj = 0
  for iphi=-180.0,+180.0,1.0 do begin
    phase[jj] = iphi
    I[ii,jj]   = I0 * phase_function(iphi,surftype[ii])
    jj = jj + 1
  endfor

endfor

; conversion from W/sterad to W/m^2 at the Earth-Moon distance from the sphere
Iearth = I/(Dem*1000.0)^2

print, phase[90],  Iearth[0,90], Iearth[1,90]
print, phase[180], Iearth[0,180], Iearth[1,180]
print, phase[270], Iearth[0,270], Iearth[1,270]



;-----------------------------------------------------------------------
; Compute the integrated moonshine (in W/m^2) as viewed from the Earth.
;-----------------------------------------------------------------------

; Moons's radius [meter]
R = Rmoon*1000.0

; surface type
surftype = ['Lambert','Lommel-Seeliger']

; geometric albedo
Ag = 0.072

; radiance from the sphere
I = dblarr(2,361)

for ii=0,1 do begin

  ; single-scattering albedo
  if strcmp(surftype[ii],'Lambert',/FOLD_CASE) then begin
    w0 = 1.5*Ag
  endif else if strcmp(surftype[ii],'Lommel-Seeliger',/FOLD_CASE) then begin
    w0 = 8.0*Ag
  endif

  ; radiance from the sphere at zero phase angle (in W/sterad)
  I0 = Ag*R^2*Isun

  ; radiance from the sphere at all phase angles (in W/sterad)
  phase = fltarr(361)
  jj = 0
  for iphi=-180.0,+180.0,1.0 do begin
    phase[jj] = iphi
    I[ii,jj]   = I0 * phase_function(iphi,surftype[ii])
    jj = jj + 1
  endfor

endfor

; conversion from W/sterad to W/m^2 at the Earth-Moon distance from the sphere
Imoon = I/(Dem*1000.0)^2


;-----------------------------------------------------------------------
; Plot
;-----------------------------------------------------------------------
set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=18,ysize=12,xoffset=0,yoffset=0
device,file=strcompress('PhaseCurve_UniformEarth.eps',/remove_all)
!p.multi = 0
loadct,39

!X.TICKS = 4
plot, /NODATA, phase, Iearth[0,*], thick=2.0, xrange=[-180,+180], yrange=1000.0*[0.00,0.10], xstyle=1, ystyle=1, xtitle='phase angle [deg]', ytitle='integrated earthshine [mW/m2]', title='Earthshine as seen from Moon', charsize=1.1, charthick=3.0
oplot, phase, 1000.0*Iearth[0,*], thick=2.0, color=70
oplot, phase, 1000.0*Iearth[1,*], thick=2.0, color=250
openw,22,'EarthshineseefromMoon.dat'
for klm=0,n_elements(phase)-1,1 do printf,22,phase[klm],Iearth[0,klm],Iearth[1,klm]
close,22

oplot, [-170,-140], 1000.0*[0.094,0.094], thick=2.0, color=70
oplot, [-170,-140], 1000.0*[0.088,0.088], thick=2.0, color=250
xyouts, -137, 1000.0*0.093, 'Lambert Earth', charsize=0.8, charthick=2.6, alignment=0.0
xyouts, -137, 1000.0*0.087, 'Lommel-Seeliger Earth', charsize=0.8, charthick=2.6, alignment=0.0

xyouts, 65, 1000.0*0.093, 'Bond albedo = 0.30', charsize=0.8, charthick=2.6, alignment=0.0

xyouts, -180.0, 1000.0*0.006, 'new Earth', orientation=25, alignment=0.5, charsize=0.9, charthick=2.6
xyouts, 0.0, 1000.0*0.006, 'full Earth', orientation=25, alignment=0.5, charsize=0.9, charthick=2.6
xyouts, 180.0, 1000.0*0.006, 'new Earth', orientation=25, alignment=0.5, charsize=0.9, charthick=2.6

device,/close


;VAR = read_ascii('C:\CygWin\home\hgl\EarthShine\Progs\MoonRef\MoonRef.out.Lambert',data_start=2,count=Nread)
;phi       = reform(VAR.field1[1,0:Nread-1])
;I_L       = VAR.field1[2,0:Nread-1]
;I_L_Lref  = VAR.field1[3,0:Nread-1]
;I_L_LSref = VAR.field1[4,0:Nread-1]
;VAR = read_ascii('C:\CygWin\home\hgl\EarthShine\Progs\MoonRef\MoonRef.out.LommelSeeliger',data_start=2,count=Nread)
;phi        = reform(VAR.field1[1,0:Nread-1])
;I_LS       = VAR.field1[2,0:Nread-1]
;I_LS_Lref  = VAR.field1[3,0:Nread-1]
;I_LS_LSref = VAR.field1[4,0:Nread-1]
;VAR = read_ascii('C:\CygWin\home\hgl\EarthShine\Progs\MoonRef\MoonRef.out.Hapke63',data_start=2,count=Nread)
;phi         = reform(VAR.field1[1,0:Nread-1])
;I_H63       = VAR.field1[2,0:Nread-1]
;I_H63_Lref  = VAR.field1[3,0:Nread-1]
;I_H63_LSref = VAR.field1[4,0:Nread-1]
;phi[0:178] = -1*phi[0:178]

set_plot,'ps'
device,/color,bits=8,encapsulated=1,xsize=18,ysize=12,xoffset=0,yoffset=0
device,file=strcompress('PhaseCurve_UniformMoon.eps',/remove_all)
!p.multi = 0
loadct,39

!X.TICKS = 4
plot, /NODATA, phase, Imoon[0,*], thick=2.0, xrange=[-180,+180], yrange=45*[0.00,0.10], xstyle=1, ystyle=1, xtitle='phase angle [deg]', ytitle='integrated moonshine [mW/m2]', title='Moonshine as seen from Earth', charsize=1.1, charthick=3.0
oplot, phase, 1000*Imoon[0,*], thick=2.0, color=70
oplot, phase, 1000*Imoon[1,*], thick=2.0, color=250
; oplot, phi, I_L,   thick=2.0, linestyle=0, color=0
; oplot, phi, I_LS,  thick=2.0, linestyle=0, color=70
; oplot, phi, I_H63, thick=2.0, linestyle=0, color=250
openw,22,'MoonshineseenfromEarth.dat'
for klm=0,n_elements(phase)-1,1 do printf,22,phase[klm],Imoon[0,klm],Imoon[1,klm]
close,22

oplot, [-170,-140], 45*[0.094,0.094], thick=2.0, color=70
oplot, [-170,-140], 45*[0.089,0.089], thick=2.0, color=250
; oplot, [-170,-140], 45*[0.084,0.084], thick=2.0, color=250
xyouts, -137, 45*0.093, 'Lambert', charsize=0.8, charthick=2.6
xyouts, -137, 45*0.088, 'Lommel-Seeliger', charsize=0.8, charthick=2.6
; xyouts, -137, 45*0.083, 'Hapke-63', charsize=0.8, charthick=2.6

xyouts, 65, 45*0.093, 'Geometric albedo = 0.1248', charsize=0.8, charthick=2.6, alignment=0.0

xyouts, -180.0, 45*0.006, 'new Moon',  orientation=25, alignment=0.5, charsize=0.9, charthick=2.6
xyouts,    0.0, 45*0.006, 'full Moon', orientation=25, alignment=0.5, charsize=0.9, charthick=2.6
xyouts,  180.0, 45*0.006, 'new Moon',  orientation=25, alignment=0.5, charsize=0.9, charthick=2.6

device,/close

END

