FUNCTION mflat_make_flat,Mdec,Mha,amask
;

if (N_elements(amask) eq 0) then amask=1b
;

Mdec=Temporary(Mdec) > 1
Mha=Temporary(Mha) > 1
;

;
s=Size(Mdec)

sx=s[1] & sy=s[2]
;
;
fdec=Mdec*(Total(Mha[*,sy/4:3*sy/4]/Mdec[*,sy/4:3*sy/4],2) # Replicate(1.0d0,sy))/double(sy)*amask
;
fha=   Mha*(Total(Mdec[sx/4:3*sx/4,*]/Mha[sx/4:3*sx/4,*],1) ## Replicate(1.0d0,sx))/double(sx)*amask
;

;
; Mdec=0b & Mha=0b
;
;
num=(sx)/6
x1=sx/2-num
x2=sx/2+num
y1=sy/2-num
y2=sy/2+num

hod=mean(fha[x1:x2,y1:y2]/fdec[x1:x2,y1:y2])

;
mask=Replicate(0b,sx)
mask[sx/3:2*sx/3] = 1b
mask=mask # Replicate(1b,sy)

fdec=Temporary(fdec)*mask+Temporary(fha)/hod*(1b-mask)

;
norm=Mean(fdec[sx/4:3*sx/4,sy/4:3*sy/4])
fdec=Temporary(fdec)/norm
;
return, fdec
end

file='MSO_sumlated.fit'
im=double(readfits(file))
idx=where(im eq 0)
im(idx)=110
im=im-110	; now there is no sky
m=256
im=congrid(im,m,m)	; change size for speed
im=im/max(im)*60000.0d0	; scale max value
mask=im*0
idx=where(im gt 0.1*max(im))
mask(idx)=1
l=size(im,/dimensions)
n=l(0)
; simulate a flat field with noise and a sloping plane
r1=randomn(seed,n,/double)/28.+.5
r2=randomn(seed,n,/double)/28.+.5
er=r1#r2/1.d0;+findgen(n,n)/float(n)/float(n)
er=er/mean(er)	; make the flat field sort of unit
im_orig=im
im=im*er
c=findgen(n)*0+1
a=total(im,1)
b=total(im,2)
md=(a#c)
ma=(b##c)
mds=md
ff=mflat_make_flat(md,ma)
!P.MULTI=[0,3,2]

surface,im,charsize=3,title='im',/lego,min=0
surface,md,charsize=3,title='md',/lego
surface,ma,charsize=3,title='ma',/lego
surface,ff*mask,charsize=3,title='ff',/lego
print,moment(ff*mask)
surface,im/ff*mask,charsize=3,title='im/ff',min=0,/lego
corr=im/ff
plot,corr(*,m/2),charsize=3
end


