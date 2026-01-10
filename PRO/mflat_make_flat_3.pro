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
print,sx,sy
;
;
fdec=Mdec*(Total(Mha[*,sy/4.:3.*sy/4.]/Mdec[*,sy/4.:3.*sy/4.],2) # Replicate(1.0d0,sy))/double(sy)*amask
;
fha=   Mha*(Total(Mdec[sx/4.:3.*sx/4.,*]/Mha[sx/4.:3.*sx/4.,*],1) ## Replicate(1.0d0,sx))/double(sx)*amask
;

;
; Mdec=0b & Mha=0b
;
;
num=(sx)/4
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


;=================================================
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\LaPalma\May27\obsrun1\IMG21.fit'
im=double(readfits(file))
help,im

m=500
im=congrid(im,m,m)
help,im

er=findgen(m,m)/float(m)/float(m)/100.0 ; 1% slope
er=er+1.0
er=er/mean(er)
;
mask=im*0.0d0 & idx=where(im gt 0.1*max(im)) & mask(idx)=1.0d0
tvscl,im*mask
l=size(im,/dimensions)
n=l(0)
c=dindgen(n)*0+1.0d0	; array of 1's
a=total(im,1) 			; project along columns
b=total(im,2)			; project along rows
md=(a#c)*er					; 'smeared image' along columns
ma=(b##c)*er					; 'smeared image' along rows
mds=md
ff=mflat_make_flat(md,ma)		; get the flat field



!P.MULTI=[0,1,1]

surface,im,charsize=3,title='im',/lego,min=0
zrange=!Z.CRANGE
surface,md,charsize=3,title='md',/lego
surface,ma,charsize=3,title='ma',/lego
surface,ff*mask,charsize=3,title='ff*mask',/lego
surface,(im/ff)*mask,charsize=3,title='im/ff',/lego
tvscl,im/ff*mask
end


