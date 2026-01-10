PRO manual_align,im,reference,offset,diff
	k=0
  	l=size(im,/dimensions)
	Nx=l(0)*1.0
	Ny=l(1)*1.0
  	offset = alignoffset(im, reference, corr)
        offset=[offset(0),offset(1),0.0]
; First get rough offset from 'alignoffset'
        shifted_im=shift_sub(im,-offset(0),-offset(1))
  window,3,xsize=512,ysize=512
  tvscl,congrid(shifted_im-reference,512,512)
key='q'
print,'Press R,L,u,d,l or r key - q to quit'
start:
	key=get_kbrd()
	print,key
	dx=0.0
	dy=0.0
        da=0.0
        da=0.0
	if (key eq 'u') then begin
	dy=0.1
	endif	
	if (key eq 'd') then begin
	dy=-0.1
	endif	
	if (key eq 'r') then begin
	dx=0.1
	endif	
	if (key eq 'l') then begin
	dx=-0.1
	endif	
	if (key eq 'R') then begin
	da=0.1
	endif	
	if (key eq 'L') then begin
	da=-0.1
	endif	
	offset(0)=offset(0)+dx
	offset(1)=offset(1)+dy
	offset(2)=offset(2)+da
  shifted_im=shift_sub(im,-offset(0),-offset(1))
  shifted_im=ROT(shifted_im,offset(2))
  window,3,xsize=512,ysize=512
  diff=(float(shifted_im)-float(reference))/float(reference)
	print,'Sum of square diff: ',total(diff^2)
  window,3,xsize=512,ysize=512
loadct,13
  tvscl,hist_equal(diff)
window,1
!P.MULTI=[0,1,2]
plot,yrange=[-100,100],diff(*,256),xtitle='Column #'
plot,yrange=[-100,100],diff(256,*),xtitle='Row #'
if (key ne 'q') then goto, start
reference=shifted_im
return
end


im=readfits('EFMCLEANED_0p7MASKED/2456034.1142920MOON_B_AIR_DCR.fits',Bhead)
reference=readfits('EFMCLEANED_0p7MASKED/2456034.1164417MOON_V_AIR_DCR.fits',Vhead)
; get the flats
Vflat=readfits('FLATS/FLATJD2455827/CFN1__V_.fits')
Bflat=readfits('FLATS/FLATJD2455827/CFN1__B_.fits')
print,'Mean and median of V flat: ',mean(Vflat),median(Vflat)
print,'Mean and median of B flat: ',mean(Bflat),median(Bflat)
ifFF='no';	write yes or no
; apply the flats
if (ifFF eq 'yes') then begin
im=im/Bflat
reference=reference/Vflat
endif
;
manual_align,im,reference,offset,diff
print,'Best fit:',offset
med=median(diff)
sd=stddev(diff)
print,'Median of diff: ',med
print,'SD of diff: ',sd
print,'Diff min,max: ',min(diff),max(diff)
idx=where(diff lt med-3*sd or diff gt med+3*sd)
help,idx
if (idx(0) ne -1) then diff(idx)=med
writefits,'shifted_im_'+ifFF+'FF.fits',reference
writefits,'realtive_diff_'+ifFF+'FF.fits',diff
end
