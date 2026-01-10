FUNCTION mflat_make_flat,Mdec,Mha,amask
; Code from Dalrymple, Bianda, Wiborg
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
fha=Mha*(Total(Mdec[sx/4:3*sx/4,*]/Mha[sx/4:3*sx/4,*],1) ## Replicate(1.0d0,sx))/double(sx)*amask
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
