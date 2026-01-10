PRO getradecstrings,arr,n
openr,1,'pos.txt'
ic=0
while not eof(1) do begin
    str=''
    readf,1,str
    a=strsplit(str,' ',/extract)
    RAstr1=a(0)
    DECstr1=a(1)
    RAstr2=a(2)
    DECstr2=a(3)
    if (ic eq 0) then arr=[RAstr1,DECstr1,RAstr2,DECstr2]
    if (ic gt 0) then arr=[[arr],[RAstr1,DECstr1,RAstr2,DECstr2]]
    ic=ic+1
    endwhile
close,1
n=ic
;print,'n position pairs:',n
return
end
