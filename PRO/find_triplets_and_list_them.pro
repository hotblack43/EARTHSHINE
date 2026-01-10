PRO gogetbeforeandafter,JDdarks,JDwant,JDbefore,JDafter,idx_before,idx_after
delta=JDdarks-JDwant
idx=where(delta  le 0)
idx_before=where(JDdarks eq JDdarks(idx(n_elements(idx)-1)))
idx=where(delta  gt 0)
idx_after=where(JDdarks eq JDdarks(idx(0)))
JDbefore=JDdarks(idx_before)
JDafter=JDdarks(idx_after)
return
end

PRO getJDfromname,str,JD
bits=strsplit(str,'/',/extract)
idx=where(strmid(bits,0,2) eq '24')
JD=double(bits(idx))
return
end

DARKnames='list.DARKS'
; firstgenerate a list of all DARK frames and their JD
openr,1,DARKnames
ic=0
while not eof(1) do begin
str1=''
readf,1,str1
bits=strsplit(str1,' ',/extract)
name=bits(1)
getJDfromname,str1,JD1
print,format='(f15.7,1x,a)',JD1,name
if (ic eq 0) then JDdarks=JD1
if (ic gt 0) then JDdarks=[JDdarks,JD1]
if (ic eq 0) then NAMEdarks=name
if (ic gt 0) then NAMEdarks=[NAMEdarks,name]
ic=ic+1
endwhile
close,1
; And then generate a list of all the MOON and their JDs
MOONnames='list.SINGLES_x0y0_MOON'
openr,1,MOONnames
ic=0
while not eof(1) do begin
str1=''
readf,1,str1
bits=strsplit(str1,' ',/extract)
name=bits(1)
getJDfromname,str1,JD1
print,format='(f15.7,1x,a)',JD1,name
if (ic eq 0) then JDmoon=JD1
if (ic gt 0) then JDmoon=[JDmoon,JD1]
if (ic eq 0) then NAMEmoon=name
if (ic gt 0) then NAMEmoon=[NAMEmoon,name]
ic=ic+1
endwhile
close,1
; and now find the DARKs that come just before and after each MOON
openw,3,'singleMOONandDARKs.txt'
for i=0,n_elements(JDmoon)-1,1 do begin
JDwant=JDmoon(i)
gogetbeforeandafter,JDdarks,JDwant,JDbefore,JDafter,idx_before,idx_after
print,format='(3(1x,f15.7),2(1x,f9.6))',JDwant,JDbefore,JDafter,JDwant-JDbefore,JDafter-JDwant
limitJD=1./24./60.
if (abs(JDwant-JDbefore) lt limitJD and abs(JDafter-JDwant) lt limitJD) then begin
print,NAMEmoon(i)
print,NAMEdarks(idx_before)
print,NAMEdarks(idx_after)
printf,3,format='(f15.7,3(1x,a))',JDwant,NAMEmoon(i),NAMEdarks(idx_before),NAMEdarks(idx_after)
endif
endfor
close,3
end
