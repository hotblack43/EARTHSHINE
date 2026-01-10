PRO getcircledprofile,psf,radius,profile
idx=where(psf eq max(psf))
coords=array_indices(psf,idx)
x0=coords(0)
y0=coords(1)
openw,33,'stuff.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
r=sqrt((i-x0)^2+(j-y0)^2)
printf,33,r,psf(i,j)
endfor
endfor
close,33
data=get_data('stuff.dat')
r=reform(data(0,*))
p=reform(data(1,*))
for rr=0,255,1 do begin
idx=where(r ge rr and r lt rr+1)
print,median(r(idx)),median(p(idx))
if (rr eq 0) then radius=median(r(idx))
if (rr eq 0) then profile=median(p(idx))
if (rr gt 0) then radius=[radius,median(r(idx))]
if (rr gt 0) then profile=[profile,median(p(idx))]
endfor
return
end

ifuseidealforobs=0
stack=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1776847MOON_V_AIR.fits.gz')
ideal=readfits('./BMINUSVWORKAREA/ideal_LunarImg_SCA_0p310_JD_2455945.1776847.fit')
writefits,'thisfile.fits',ideal
ideal=ideal/total(ideal)
for i=0,99,1 do begin
obs=readfits('/data/pth/DARKCURRENTREDUCED/2455945.1776847MOON_V_AIR_DCR.fits')
obs=reform(stack(*,*,i));-397
; make the obs from folded ideal
if (ifuseidealforobs eq 1) then begin
str='./justconvolve thisfile.fits outfile.fits 1.7'
spawn,str
obs=readfits('outfile.fits')
endif
if (ifuseidealforobs ne 1) then begin
obs=reverse(obs,1)
shifts=alignoffset(obs,ideal)
print,'Shifts are: ',shifts
obs=shift_sub(obs,-shifts(0),-shifts(1))
endif
obs=obs/total(obs)
; deconvolve
psf_here=fft(fft(obs,-1,/double)/fft(ideal,-1,/double),1,/double)
psf_here=double(sqrt(psf_here*conj(psf_here)))
psf_here=shift(psf_here,255,255)
if (i eq 0) then begin
	psf_stack=psf_here
        psf=psf_here
endif
if (i gt 0) then begin
	psf_stack=[[[psf_stack]],[[psf_here]]]
        l=size(psf_stack,/dimensions)
        nstaked=l(2)
	psf=avg(psf_stack,2)
endif
getcircledprofile,psf,radius,profile
!P.CHARSIZE=2
!P.THICK=4
!X.thick=3
!y.thick=3
plot_oo,radius,profile,xrange=[.1,300],title=string(i)+' th frame.'
endfor
end
