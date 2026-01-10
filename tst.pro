for i=1,100,1 do begin
single_scattering=randomu(seed)
SCAnum=strcompress(string(single_scattering),/remove_all)
idx = STRPOS(SCAnum,'.')
part1=strmid(SCAnum,0,1)
part2=strmid(SCAnum,idx+1,strlen(SCAnum)+1)
SCAnumstr=strcompress(part1+'p'+part2,/remove_all)
print,single_scattering,' ',SCAnumstr
print,'---------------------'
endfor
end
