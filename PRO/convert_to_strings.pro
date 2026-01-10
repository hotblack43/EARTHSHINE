PRO convert_to_strings,mm,dd,yy,hh,min,sec,secstring,datestring,UTtimestring
;
        if (mm le 9) then mostring='0'+string(mm)
        if (mm ge 10) then mostring=string(mm)
        if (dd le 9) then ddstring='0'+string(dd)
        if (dd ge 10 ) then ddstring=string(dd)
        if (hh le 9) then hhstring='0'+string(hh)
        if (hh ge 10) then hhstring=string(hh)
        if (min le 9) then minstring='0'+string(min)
        if (min ge 10) then minstring=string(min)
        secstring=string(sec,format='(f5.2)')
        datestring=strcompress(string(yy)+'-'+mostring+'-'+ddstring,/remove_all)
        UTtimestring=strcompress(hhstring+':'+minstring+':'+secstring,/remove_all)
return
end
