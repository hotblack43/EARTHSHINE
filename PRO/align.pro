files=file_search('IMG*.tif',count=n)
for i=0,n-1,1 do begin
im=read_tiff(files(i))
if (i eq 0) then begin
Rstack=reform(im(0,*,*))
Gstack=reform(im(1,*,*))
Bstack=reform(im(2,*,*))
endif else begin
Rstack=[[[Rstack]],[[reform(im(0,*,*))]]]
Gstack=[[[Rstack]],[[reform(im(1,*,*))]]]
Bstack=[[[Rstack]],[[reform(im(2,*,*))]]]
endelse
endfor
;
l=size(Rstack,/dimensions)
Nims=l(2)
print,'There are ',Nims,' images in the stack.'
niter=5
Rref=reform(Rstack(*,*,0))
tvscl,congrid(Rref,500,800)
Gref=reform(Gstack(*,*,0))
Bref=reform(Bstack(*,*,0))
for iter=0,niter-1,1 do begin
d=0.0
print,'Alignment iteration ',iter
for i=0,Nims-1,1 do begin
R=reform(Rstack(*,*,i))
G=reform(Gstack(*,*,i))
B=reform(Bstack(*,*,i))
Roffset=alignoffset(R,Rref)
Goffset=alignoffset(G,Gref)
Boffset=alignoffset(B,Bref)
d=d+Roffset(0)^2 +Roffset(1)^2
print,i,Roffset
Rstack(*,*,i)=shift_sub(R,-Roffset(0),-Roffset(1))
Gstack(*,*,i)=shift_sub(G,-Goffset(0),-Goffset(1))
Bstack(*,*,i)=shift_sub(R,-Boffset(0),-Boffset(1))
endfor
Rref=avg(Rstack,2)
Gref=avg(Gstack,2)
Bref=avg(Bstack,2)
tvscl,hist_equal(congrid(Rref,500,800))
print,'Total offset this iteration: ',d
endfor
writefits,'RGB_aligned.fits',[[[Rref]],[[Gref]],[[Bref]]]
end
