PRO selectwithmouse,x,y,idx
 ;
 print,'Upper left, click'
 cursor,xl,yu
 wait,.4
 print,'lower right, click'
 cursor,xr,yd
 wait,.4
 idx=where(x ge xl and x le xr and y gt yd and y le yu)
 oplot,x(idx),y(idx),color=fsc_color('red'),psym=7
 return
 end
 
 FUNCTION youngairmass,z
 ; z is the zenith distance in degrees
 numerator=(1.002432*cos(z*!dtor)*cos(z*!dtor)+0.148386*cos(z*!dtor)+0.0096467)
 denominator=(cos(z*!dtor)*cos(z*!dtor)*cos(z*!dtor)+0.149864*cos(z*!dtor)*cos(z*!dtor)+0.0102963*cos(z*!dtor)+0.000303978)
 am=numerator/denominator
 return,am
 end
 
 ; get the Allen table
 data=get_data('lunar_irradiance_Allen.dat')
 ALLENph=reform(data(0,*))
 ALLENfl=reform(data(1,*))
 fnames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 sum=0
;....
; get the table of fluxes and phases from the NEW eshine model
data=get_data('other.new.moonbrightness.tab')
synphase=reform(data(1,*))+180.
synflux=reform(data(2,*))
;....
 openw,92,'exposure_scaling_info.dat'
 for i=0,4,1 do begin
     openw,77,strcompress('DUDinfo_'+fnames(i)+'.txt',/remove_all)
     !P.MULTI=[0,2,3]
     !P.CHARSIZE=1.4
     !P.THICK=2
     !x.THICK=2
     !y.THICK=2
     file='observed_fluxes.dat'
     spawn,'grep '+fnames(i)+' '+file+" | grep -v DITHER | grep -v SKE | awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' > aha.dat"
     spawn,'grep '+fnames(i)+' '+file+" | grep -v DITHER | grep -v SKE |  awk '{print $9}' > names.dat"
     spawn,'grep '+fnames(i)+' '+file+" | grep -v DITHER | grep -v SKE |  awk '{print $10}' > filenames.dat"
     ; get and select data
     data=get_data('aha.dat')
     data_names=get_data_string('filenames.dat')
     altitude=reform(data(4,*))
     sunalt=reform(data(5,*))
     sunlimit=-1.
	moonlimit=20.
     kdx=where(sunalt lt sunlimit and altitude gt moonlimit)
     data=data(*,kdx)
     data_names=reform(data_names(0,kdx))
     jd=reform(data(0,*))
     flux=reform(data(1,*))
     expt=reform(data(2,*))
     phase=reform(data(3,*))
     altitude=reform(data(4,*))
     sunalt=reform(data(5,*))
     DSBS=reform(data(6,*))
     maxcount=reform(data(7,*))
     airmass=youngairmass(90.-altitude)
     ;
     k=0.15	; estimate!
     if (fnames(i) eq '_B_') then k=0.3	; ! estimate from La SIlla
     fluxcorr=1.+k*airmass
     print,k
;----------------------
;    ; interpolate to ALlen table
;    intflu=INTERPOL(ALLENfl,ALLENph,phase)
;    ; just the geometric illumination fraction
;    mphase2,jd,fraction
;    ; Pick the phase correction
;    ;intflu=intflu
;    intflu=fraction^1.8
;----------------------
; using the synthetic fluxes instead
intflu=INTERPOL(synflux,abs(synphase),abs(phase))
;intflu=intflu^1.7
;----------------------
     plot_io,phase,flux,psym=1,xtitle='Phase [0 = FM]',ytitle='Flux',title=fnames(i)
     plot_io,phase,flux*fluxcorr,psym=1,xtitle='Phase [0 = FM]',ytitle='Flux (ext. corrected)',title=fnames(i)
     plot_io,phase,flux*fluxcorr/intflu,psym=1,xtitle='Phase [0 = FM]',ytitle='Flux (ext. corr ) / model',title=fnames(i)
     x=phase & y=flux*fluxcorr/intflu
;    selectwithmouse,x,y,idx 

for klmn=0,n_elements(idx)-1,1 do begin
printf,77,format='(f15.6,1x,f17.8,1x,a)',jd(idx(klmn)),sunalt(idx(klmn)),data_names(idx(klmn))
endfor

plot_io,phase,DSBS,psym=1,xtitle='Phase [0 = FM]',ytitle='DS/BS',title=fnames(i),ystyle=3
     z=alog10(flux*fluxcorr/intflu)
     !P.CHARSIZE=1.0
     histo,z,min(z),max(z),(max(z)-min(z))/100.,xtitle='log!d10!n[Flux (ext. corr + Phase corr)]'
     here=n_elements(phase)
     sum=sum+here
; print the info on exposure time scaling
nml=n_elements(phase)
for kl=0,nml-1,1 do begin
	printf,92,format='(1x,f7.1,1x,f9.5,1x,f10.1,1x,a)',phase(kl),expt(kl),maxcount(kl),fnames(i)
endfor
     close,77
     endfor
 print,'Number of data: ',sum
     close,92
 end
