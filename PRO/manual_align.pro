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
	dy=0.5
	endif	
	if (key eq 'd') then begin
	dy=-0.5
	endif	
	if (key eq 'r') then begin
	dx=0.5
	endif	
	if (key eq 'l') then begin
	dx=-0.5
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
  diff=float(shifted_im)-float(reference)
  tvscl,diff
if (key ne 'q') then goto, start
im=shifted_im
return
end
