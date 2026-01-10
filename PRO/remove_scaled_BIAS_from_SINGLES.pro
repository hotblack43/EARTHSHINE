PRO gogetRON,dark1,dark2,RON
RON=stddev(dark1-dark2)/sqrt(2.)
return
end

PRO getthebasename,m_name,nameofoutfile
bits=strsplit(m_name,'/',/extract)
idx=strpos(bits,'24')
nameofoutfile=bits(where(idx eq 0))
return
end

bias=readfits('superbias.fits',/sil)
openr,1,'singleMOONandDARKs.txt'
while not eof(1) do begin
str=''
readf,1,str
bits=strsplit(str,' ',/extract)
m_name=bits(1)
d1_name=bits(2)
d2_name=bits(3)
im=readfits(m_name,h,/sil)
tvscl,hist_equal(im)
d1=readfits(d1_name,/sil)
d2=readfits(d2_name,/sil)
factor=((mean(d1,/double)+mean(d2,/double))/2.0d0)/mean(bias,/double)
subtractor=bias*factor
im=im-subtractor
getthebasename,m_name,nameofoutfile
bits=strsplit(m_name,'/',/extract)
stripmax=max(avg(im(*,0:20),1))
print,mean(im(0:40,0:40)),factor,stripmax
if (stripmax le 20) then begin
  gogetRON,d1,d2,RON
     print,'Found RON:',ron
     sxaddpar, h, 'RON', ron, ' RON=S.D.(dark1-dark2)/sqrt(2)'
     sxaddpar, h, 'BIASFACTOR', factor, ' superbias scaled by this factor.'
	writefits,strcompress('SELECTED_5/'+nameofoutfile,/remove_all),im,h
endif
endwhile
close,1
end
