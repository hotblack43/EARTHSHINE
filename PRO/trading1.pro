/****f* SearchProj/simple_search
* NAME
* simple_search: searches for a key- word in a array
* USAGE
* simple_search(keyword)
* FUNCTION
* Accepts a keyword as a parameter
* Iterates through the elemen-ts of the array
* And returns true if the keyword is found else returns false
* PARAMETERS
* keyword - the keyword to sear-ch for 
* RETURN VALUE
* true or false
/***
*/
FUNCTION method1,n
; white noise series
series=randomn(seed,n)+20.0
idx=where(series le 0.0)
if (idx(0) ne -1) then series(idx)=5
return,series
end

FUNCTION method2,n
; red noise series
series=randomn(seed,n)+20.0
idx=where(series le 0.0)
if (idx(0) ne -1) then series(idx)=5
series=pseudo_t_guarantee_ac1(series,0.99,1,seed)
return,series
end

FUNCTION method3,n
; red noise series + trend
series=randomn(seed,n)+20.0
idx=where(series le 0.0)
if (idx(0) ne -1) then series(idx)=5
series=pseudo_t_guarantee_ac1(series,0.99,1,seed)+indgen(n)*0.005
return,series
end

FUNCTION method4,n
; white noise series
series=randomn(seed,n)+20.0
idx=where(series le 0.0)
if (idx(0) ne -1) then series(idx)=5
series=series+indgen(n)*0.01
return,series
end

PRO buy,index,itime,holding,capital,buyfor
nbuy=fix(buyfor/index(itime))	; you can buy this many stocks at time itime
cost=nbuy*index(itime)			;	cost of what you bought
if (cost le capital) then begin
	capital=capital-cost
	holding=holding+nbuy
endif
return
end

PRO sell,index,itime,holding,capital,howmanytosell
nsell=fix(howmanytosell)
valueofsold=nsell*index(itime)
capital=capital+valueofsold
holding=holding-nsell
return
end

PRO strategy,index,itime,what_to_do
if (index(itime) ge index(itime-1) )  then what_to_do=0	; buy if rising
if (index(itime) lt index(itime-1))  then what_to_do=1	; sell if dropping
return
end

!P.MULTI=[0,1,2]
ntries=100
fairing=fltarr(ntries)
n=500	;	number of trading opportunities
worth=fltarr(n)
for itry=0,ntries-1,1 do begin
index=method3(n)	; generate the stock index
plot,index,ytitle='Stock index',ystyle=1
capital=100000	; initial capital
holding=1000	; initial holding
worth(0)=capital+holding*index(0)
;---------------------
for itime=2,n-1,1 do begin
	worth(itime)=capital+holding*index(itime)
	strategy,index,itime,what_to_do
	if (what_to_do eq 0) then buy,index,itime,holding,capital,0.1*capital	; buy with 20% of capital
	if (what_to_do eq 1) then sell,index,itime,holding,capital,0.2*holding	; sell 20% of holdings
	endfor
	plot,worth,ystyle=1
print,itry,'Change in worth:',worth(n-1)-worth(0)
fairing(itry)=worth(n-1)-worth(0)
endfor
!P.MULTI=[0,1,1]
histo,fairing,min(fairing),max(fairing),5000
end
