Bdata=get_data('JD_alfa_B_.dat')
Vdata=get_data('JD_alfa_V_.dat')
VE1data=get_data('JD_alfa_VE1_.dat')
VE2data=get_data('JD_alfa_VE2_.dat')
IRCUTdata=get_data('JD_alfa_IRCUT_.dat')
B_JD=reform(Bdata(0,*))
B_alfa=reform(Bdata(1,*))
nB=n_elements(B_JD)
V_JD=reform(Vdata(0,*))
V_alfa=reform(Vdata(1,*))
nV=n_elements(V_JD)
VE1_JD=reform(VE1data(0,*))
VE1_alfa=reform(VE1data(1,*))
nVE1=n_elements(VE1_JD)
VE2_JD=reform(VE2data(0,*))
VE2_alfa=reform(VE2data(1,*))
nVE2=n_elements(VE2_JD)
IRCUT_JD=reform(IRCUTdata(0,*))
IRCUT_alfa=reform(IRCUTdata(1,*))
nIRCUT=n_elements(IRCUT_JD)
; search for close B and V alfas
print,'---------------------------------------'
print,'B and V'
for i=0,nV-1,1 do begin
JDdiff=B_JD-V_JD(i)
alfadiff=B_alfa-V_alfa(i)
idx=where(abs(JDdiff) lt 1./24./2. and abs(alfadiff) lt 0.001)
if (idx(0) ne -1) then begin
for k=0,n_elements(idx)-1,1 do begin
	print,format='(i3,1x,i3,2(1x,f15.7),2(1x,f6.4))',i,k,B_JD(idx(k)),V_JD(i),B_alfa(idx(k)),V_alfa(i)
endfor
endif
endfor
; search for close VE1 and V alfas
print,'---------------------------------------'
print,'VE1 and VE2'
for i=0,nVE1-1,1 do begin
JDdiff=VE2_JD-VE1_JD(i)
alfadiff=VE2_alfa-VE1_alfa(i)
idx=where(abs(JDdiff) lt 1./24./2. and abs(alfadiff) lt 0.001)
if (idx(0) ne -1) then begin
fmt='(i3,1x,i3,2(1x,f15.7),3(1x,f7.4))'
for k=0,n_elements(idx)-1,1 do begin
print,format=fmt,i,k,VE2_JD(idx(k)),VE1_JD(i),VE2_alfa(idx(k)),VE1_alfa(i),alfadiff(i)
endfor
endif
endfor
end

