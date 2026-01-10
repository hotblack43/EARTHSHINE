openw,33,'LAMPFLATND.middle'
for i=0,20,1 do begin
expt_factor=randomu(seed)
printf,33,'SETFILTERCOLORDENSITY,V,AIR,,,,,,,'
printf,33,'SETFOCUSPOSITION,V_AIR_SKE,,,,,,,,'
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
printf,33,strcompress('SHOOTKINETIC,'+string(1.7*expt_factor)+',20,512,512,LAMP_FLAT_V_AIR,,,,',/remove_all)
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
printf,33,'SETFILTERCOLORDENSITY,V,ND1.0,,,,,,,'
printf,33,'SETFOCUSPOSITION,V_AIR_ND,,,,,,,,'
printf,33,strcompress('SHOOTKINETIC,'+string(17.*expt_factor)+',20,4,512,LAMP_FLAT_V_ND1.0,,,,',/remove_all)
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
printf,33,'SETFILTERCOLORDENSITY,V,ND1.3,,,,,,,'
printf,33,strcompress('SHOOTKINETIC,'+string(33.15*expt_factor)+',2,512,512,LAMP_FLAT_V_ND1.3,,,,',/remove_all)
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
printf,33,'SETFILTERCOLORDENSITY,V,ND2.0,,,,,,,'
printf,33,strcompress('SHOOTKINETIC,'+string(170.0*expt_factor)+',1,512,512,LAMP_FLAT_V_ND2.0,,,,',/remove_all)
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
endfor
close,33
spawn,'cat LAMPFLATND.bit1 > all.out'
spawn,'cat LAMPFLATND.middle >> all.out'
spawn,'cat LAMPFLATND.bit2 >> all.out'
end
