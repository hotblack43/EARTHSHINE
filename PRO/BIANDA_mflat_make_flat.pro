; Code from Dalrymple, Bianda, Wiborg
;
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

n=1024/16
a=(abs(findgen(n)-n/2))^2
b=1.-a/max(a)
c=fltarr(n)+1.
r1=randomn(seed,n)/38.+.5
r2=randomn(seed,n)/38.+.5
er=r1#r2/10.d0;+findgen(n,n)/float(n)/float(n)
er=er/mean(er)
md=(b#c)*1000.d0*er
ma=(b##c)*1000.d0*er
help,md,ma
mds=md
help,md,ma,er
ff=mflat_make_flat(md,ma)
device,decomposed=0
loadct,9
!P.MULTI=[0,2,2]

surface,ff,charsize=2,title='ff',/lego
end
