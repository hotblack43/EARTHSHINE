
for kjd=double(julday(1,1,2011)),double(julday(1,1,2012)),1.0d0 do begin
        mphase,kjd,k
        phase=(acos(2.*k-1.)/!dtor)
	caldat,kjd,mm,dd,yy
	print,mm,dd,yy,k,phase
endfor
end

