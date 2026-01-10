PRO get_the_flux,bias,string,flux
fname=strcompress('TEMPSTORAGE/*'+string+'*.fits',/remove_all)
;print,'Looking for:',fname
files=file_search(fname,count=nv)
for i=0,nv-1,1 do begin
if (i eq 0) then sum=readfits(files(i),header,/silent)
if (i gt 0) then sum=sum+readfits(files(i),header,/silent)
parseheader,header,'EXPOSURE',exposuretime
endfor
v=sum/float(nv)-bias
flux=median(v)/exposuretime
return
end

PRO parseheader,header,findthis,outvalue
l=fix(size(header,/dimensions))
l=l(0)
for i=0,l-1,1 do begin
idx=strpos(header(i),findthis)
if (idx(0) ne -1) then begin
	outvalue=float(strmid(header(i),9,20))
;	print,outvalue
endif
endfor
return
end

files=file_search('TEMPSTORAGE/*BIAS*.fits',count=nbias)
for i=0,nbias-1,1 do begin
if (i eq 0) then sum=readfits(files(i),/silent)
if (i gt 0) then sum=sum+readfits(files(i),/silent)
endfor
bias=sum/float(nbias)
;AIR
get_the_flux,bias,'AIRAIR',AIRflux
print,'AIR flux:',AIRflux,' counts/second.',AIRflux/AIRflux,' relative to AIR'
;B
get_the_flux,bias,'BAIR',bflux
print,'B flux:',bflux,' counts/second.',bflux/AIRflux,' relative to AIR'
;V
get_the_flux,bias,'VAIR',vflux
print,'V flux:',vflux,' counts/second.',vflux/AIRflux,' relative to AIR'
;VE1
get_the_flux,bias,'VE1AIR',ve1flux
print,'VE1 flux:',ve1flux,' counts/second.',ve1flux/AIRflux,' relative to AIR'
;VE2
get_the_flux,bias,'VE2AIR',ve2flux
print,'VE2 flux:',ve2flux,' counts/second.',ve2flux/AIRflux,' relative to AIR'
;IRCUT
get_the_flux,bias,'IRCUTAIR',IRCUTflux
print,'IRCUT flux:',IRCUTflux,' counts/second.',IRCUTflux/AIRflux,' relative to AIR'
end
