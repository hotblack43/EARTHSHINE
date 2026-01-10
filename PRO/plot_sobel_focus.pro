close,/all
JDstr='2456017'
!P.MULTI=[0,1,2]
filters=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
for filterpointer=0,n_elements(filters)-1,1 do begin
openw,2,'plotme.dat'
openr,1,'typescript';'sobel_focus.dat'
while not eof(1) do begin
str=''
readf,1,str
bits=strsplit(str,' ',/extract)
print,bits
if (bits(0) eq filters(filterpointer)) then printf,2,bits(1),' ',bits(3)
endwhile
close,2
data=get_data('plotme.dat')
idx=where(long(data(0,*)) eq JDstr)
if (idx(0) ne -1) then begin
data=data(*,idx)
histo,reform(data(1,*)),0.03,0.11,0.001,/abs,title=filters(filterpointer)
plot,title=JDstr,data(0,*)-long(data(0,*)),data(1,*),psym=7,xstyle=3,ystyle=3,xtitle='fr. JD',ytitle='Focus #'
endif
close,1
endfor
end
