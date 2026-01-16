PRO rnd_filename,filename
;
; will generate a random filename 
;
;n=10
;digits=fix(randomu(seed,n)*100)
;str=''
;for i=0,n-1,1 do str=str+string(digits(i))
;str=strcompress(str,/remove_all)+'.randomfile'
;filename=str
filename=strcompress(string(long(randomu(seed)*1000000))+'.randomfile',/remove_all)
return
end
