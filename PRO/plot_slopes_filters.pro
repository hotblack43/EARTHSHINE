filters=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
for ifilter=0,n_elements(filters)-1,1 do begin
openw,2,'plotme.dat'
openr,1,'slopes_filters.dat'
while not eof(1) do begin
str=''
readf,1,str
bits=strsplit(str,' ',/extract)
if (bits(1) eq filters(ifilter)) then printf,2,bits(0)
endwhile
close,2
data=get_data('plotme.dat')
print,data,filters(ifilter)
if (ifilter eq 0) then histo,data,1,4,0.5,/abs
if (ifilter gt 0) then histo,data,1,4,0.5,/overplot,/abs
close,1
endfor
end
