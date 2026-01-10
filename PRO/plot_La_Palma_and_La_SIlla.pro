; ---------------- MAIN PROG ---------------
files=['La_Palma_extinction_on_good_nights.dat','lasilla_1977_1996_yymmddhhmi.dat']
nfiles=n_elements(files)
!P.MULTI=[0,1,2]
for ifil=0,nfiles-1,1 do begin
file=files(ifil)
if (ifil eq 0) then begin
data=get_data(file) & year=reform(data(0,*)) & mm=reform(data(1,*)) & dd=reform(data(2,*)) & hr=reform(data(3,*)) & mi=reform(data(4,*)) & ext0=reform(data(5,*)) & err=reform(data(6,*))
jd0=julday(mm,dd,year,hr)
fracyear0=year+(mm-1)/12.+dd/365.25
plot,fracyear0,ext0,psym=3,xrange=[1977,2005],xstyle=1,title='La Palma',ytitle='Extinction (mags)'
endif
if (ifil eq 1) then begin
data=get_data(file) & year=reform(data(0,*)) & mm=reform(data(1,*)) & dd=reform(data(2,*)) & hr=reform(data(3,*)) & mi=reform(data(4,*)) & ext1=reform(data(5,*)) & err=reform(data(6,*))
jd1=julday(mm,dd,year,hr)
fracyear1=year+(mm-1)/12.+dd/365.25
plot,fracyear1,ext1,psym=3,xrange=[1977,2005],xstyle=1,title='La Silla',ytitle='kV extinction (mags)'
endif

endfor
openw,14,'lasilla_lapalma.dat'
for jd=max([min(jd0),min(jd1)]),min([max(jd0),max(jd1)]),1 do begin
idx=where(long(jd0) eq long(jd))
jdx=where(long(jd1) eq long(jd))
if (idx(0) ne -1 and jdx(0) ne -1) then begin
	printf,14,jd,ext0(idx(0)),ext1(jdx(0))
endif
endfor
close,14
data=get_data('lasilla_lapalma.dat')
x=reform(data(0,*))
ext0=reform(data(1,*))
ext1=reform(data(2,*))
stop
!P.MULTI=[0,1,1]
plot,ext0,ext1,psym=7,xtitle='La Palma extinction',ytitle='La SIlla extinction',charsize=1.8
end