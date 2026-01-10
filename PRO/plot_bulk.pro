col=['blue','green','yellow','red','orange']
 data=get_data('bulk_nights.dat')
 filter=reform(data(2,*))
 x=reform(data(3,*))
 xer=reform(data(4,*))
 y=reform(data(5,*))
 yer=reform(data(6,*))
 chi2red=reform(data(7,*))
 print,'minmax chi2red: ',min(chi2red),max(chi2red)
 idx=where(chi2red lt 4 and chi2red gt 0.25)
 ploterror,x(idx),y(idx),xer(idx),yer(idx),psym=3,xtitle='Albedo (all bands)',charsize=1.8,ytitle='!7D!3k',title='Night results'
 oplot,[!X.crange],[0,0],linestyle=1
 oplot,[!X.crange],[0.009,0.009],linestyle=2
 oplot,[!X.crange],[0.0135,0.0135],linestyle=2
 for i=1,5,1 do begin
     idx=where(filter eq i)
     if (n_elements(idx) ge 2) then oplot,x(idx),y(idx),color=fsc_color(col(i-1)),psym=7
     endfor
 end
