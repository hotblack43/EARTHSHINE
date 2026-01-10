PRO buy,bank,holding,cost,price
buy=0.1*bank	; amount to buy for
bank=bank-buy - cost*(buy/price) ; remains in cash
holding=holding+buy/price ; number of stocks owned
if (bank lt 0) then stop
return
end
PRO sell,bank,holding,cost,price
sell=0.1*holding ; number of shares to sell
bank=bank+sell*price - sell*cost ; cash in bank after
holding=holding-sell   ; number of shares owned after
if (holding lt 0) then stop
return
end

;=====================
sum=0
ntries=1
npoints=365
for ntry=0,ntries-1,1 do begin
x=1000+randomn(seed,npoints)
;x=pseudo_t_guarantee_ac1(x,0.77,1,seed)
x=x-indgen(npoints)/30.
plot,x,ystyle=1
start_bank=1000
start_holding=1000
bank=start_bank
holding=start_holding
start_wealth=bank+holding*x(0)
cost=0.1

for i=1,npoints-1,1 do begin
if (x(i) le x(i-1)) then buy,bank,holding,cost,x(i)
if (x(i) gt x(i-1)) then sell,bank,holding,cost,x(i)
endfor
end_wealth=bank+holding*x(npoints-1)
change=end_wealth-start_wealth
;print,end_wealth,start_wealth
sum=sum+change
endfor
print,sum
end