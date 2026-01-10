Return-Path: <pth@dmi.dk>
Received: from fep28.mail.dk ([130.226.71.185]) by fep33.mail.dk
          (InterMail vM.6.01.06.00 201-2131-130-20051209) with ESMTP
          id <20060116080216.GSCL16598.fep33.mail.dk@fep28.mail.dk>
          for <thejll@mail.dk>; Mon, 16 Jan 2006 09:02:16 +0100
Received: from mailgw.dmi.dk ([130.226.71.185]) by fep28.mail.dk
          (InterMail vG.2.02.00.00 201-2161-120-101-20051020) with ESMTP
          id <20060116080215.PYJC28632.fep28.mail.dk@mailgw.dmi.dk>
          for <thejll@mail.dk>; Mon, 16 Jan 2006 09:02:15 +0100
Received: from localhost (localhost.dmi.dk [127.0.0.1])
	by mailgw.dmi.dk (8.12.11/8.12.11/Debian-1) with ESMTP id k0G82Dei008187
	for <thejll@mail.dk>; Mon, 16 Jan 2006 08:02:13 GMT
Received: from mailgw.dmi.dk ([127.0.0.1])
	by localhost (mailgw.dmi.dk [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 08017-08-2 for <thejll@mail.dk>;
	Mon, 16 Jan 2006 08:02:12 +0000 (GMT)
Received: from postoffice.dmi.dk (postoffice.dmi.dk [130.226.64.60])
	by mailgw.dmi.dk (8.12.11/8.12.11/Debian-1) with ESMTP id k0G829QE008160
	for <thejll@mail.dk>; Mon, 16 Jan 2006 08:02:09 GMT
Received: from localhost (localhost.dmi.dk [127.0.0.1])
	by postoffice.dmi.dk (Postfix) with ESMTP id E6FEB1810F
	for <thejll@mail.dk>; Mon, 16 Jan 2006 08:02:08 +0000 (GMT)
Received: from postoffice.dmi.dk ([127.0.0.1])
	by localhost (postoffice.dmi.dk [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 24237-01-11 for <thejll@mail.dk>;
	Mon, 16 Jan 2006 08:02:08 +0000 (GMT)
Received: from smasher.dmi.dk (smasher [130.226.66.180])
	by postoffice.dmi.dk (Postfix) with ESMTP id B511618103
	for <thejll@mail.dk>; Mon, 16 Jan 2006 08:02:08 +0000 (GMT)
Received: from pth by smasher.dmi.dk with local (Exim 3.36 #1 (Debian))
	id 1EyPJY-0000fo-00
	for <thejll@mail.dk>; Mon, 16 Jan 2006 09:02:08 +0100
To: thejll@mail.dk
Message-Id: <E1EyPJY-0000fo-00@smasher.dmi.dk>
From: Peter Thejll <pth@dmi.dk>
Date: Mon, 16 Jan 2006 09:02:08 +0100
X-Virus-Scanned: by amavisd-new-20030616-p10 (Debian) at dmi.dk
X-Virus-Scanned: by amavisd-maia-1.0.0-rc5 (Debian) at dmi.dk

FUNCTION fractional_operator,z,d
y=double(z)
sum=y*0.0d0
nbig=30
for j=0,nbig,1 do begin
factor=gamma(j-d)/(gamma(j+1)*gamma(-d))
sum=sum+factor*shift(y,j)
endfor
res=sum
return,res
end

!P.MULTI=[0,1,3]
file='annual_co2.data'
file='annualvonStorchSolar.dat'
file='annualvonStorch_ln_CO2.dat'
file='annualvonStorchCO2.dat'
file='annualvonStorchNHT.dat'
file='mann_nhem.data'
file='/home/pth/DATA/annual_total_irradiance_Lean95.dat'
file='/home/pth/DATA/volcanic.dat'
file='/home/pth/G3526/local_1/thejll/SPURIOUS/annual_log_co2.dat'

res=read_ascii(file,record_start=1)
year=res.field1(0,*)
NHT=res.field1(1,*)
y=NHT
; apply operator
for d=-0.9,1.5,0.025 do begin
print,'==================================================='
print,'d=',d
res=fractional_operator(y,d)
if_plot=1
bartlett_test,res,if_plot
endfor
end