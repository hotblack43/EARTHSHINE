X-Account-Key: account2
X-UIDL: <20100515144419.919FF4E25B@pandora.dmi.dk>
X-Mozilla-Status: 0001
X-Mozilla-Status2: 00000000
X-Mozilla-Keys:                                                                                 
Return-Path: <pth@dmi.dk>
Received: from fep28.mail.dk ([130.226.71.185]) by fep35.mail.dk
          (InterMail vM.7.09.02.02 201-2219-117-103-20090326) with ESMTP
          id <20100515144624.JERA6178.fep35.mail.dk@fep28.mail.dk>
          for <thejll@mail.dk>; Sat, 15 May 2010 16:46:24 +0200
Received: from mailgw.dmi.dk ([130.226.71.185]) by fep28.mail.dk
          (InterMail vG.3.00.04.00 201-2196-133-20080908) with ESMTP
          id <20100515144624.OQPM9312.fep28.mail.dk@mailgw.dmi.dk>
          for <thejll@mail.dk>; Sat, 15 May 2010 16:46:24 +0200
Received: from localhost (localhost.dmi.dk [127.0.0.1])
	by mailgw.dmi.dk (8.12.3/8.12.11/Debian-1) with ESMTP id o4FEkMFk023389
	for <thejll@mail.dk>; Sat, 15 May 2010 14:46:22 GMT
Received: from mailgw.dmi.dk ([127.0.0.1])
	by localhost (mailgw.dmi.dk [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 22419-01-6 for <thejll@mail.dk>;
	Sat, 15 May 2010 14:46:21 +0000 (GMT)
Received: from mailserver.dmi.dk (postoffice.dmi.dk [130.226.64.60])
	by mailgw.dmi.dk (8.12.3/8.12.3/Debian-7.2) with ESMTP id o4FEiKj5022728
	for <thejll@mail.dk>; Sat, 15 May 2010 14:44:20 GMT
Received: from localhost (localhost.dmi.dk [127.0.0.1])
	by mailserver.dmi.dk (Postfix) with ESMTP id 23CD7366AF6
	for <thejll@mail.dk>; Sat, 15 May 2010 14:44:20 +0000 (GMT)
Received: from mailserver.dmi.dk ([127.0.0.1])
	by localhost (postoffice.dmi.dk [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 19926-01-25 for <thejll@mail.dk>;
	Sat, 15 May 2010 14:44:20 +0000 (GMT)
Received: from pandora.dmi.dk (egregious [130.226.67.115])
	by mailserver.dmi.dk (Postfix) with ESMTP id 11B70366A64
	for <thejll@mail.dk>; Sat, 15 May 2010 14:44:20 +0000 (GMT)
Received: by pandora.dmi.dk (Postfix, from userid 1099)
	id 919FF4E25B; Sat, 15 May 2010 16:44:19 +0200 (CEST)
To: thejll@mail.dk
Subject: moo
Message-Id: <20100515144419.919FF4E25B@pandora.dmi.dk>
Date: Sat, 15 May 2010 16:44:19 +0200 (CEST)
From: pth@dmi.dk (Peter Thejll)
X-Virus-Scanned: Debian amavisd-new at dmi.dk
X-Virus-Scanned: by amavisd-maia-1.0.0-rc5 (Debian) at dmi.dk
X-CM-Analysis: v=1.1 cv=WHkRfWUd+BQrbCFhk1BYvAPoEKcO3VjqDAMaGEz+15Y= c=1 sm=0 a=_9sbqr5ShY8A:10 a=ORa4HqFjfvEA:10 a=K4R8LXkrXniH8spjYSGWBg==:17 a=0TMIDoUG8UYw7Dr3rzQA:9 a=Vdd81Ps4ltKRZGenLnrY-gtalLsA:4 a=HpAAvcLHHh0Zw7uRqdWCyQ==:117

JDstart=double(julday(1,1,2011,0,0,0))
JDstop=double(jdstart+370.)
jdstep=1./24./4.
obsname='lapalma'
openw,5,'p.dat'
for jd=jdstart,jdstop,jdstep do begin
	mphase,jd, k
MOONPOS, jd, alpha, delta, dis
eq2hor, alpha, delta, jd, alt_moon, az, ha,  OBSNAME=obsname
SUNPOS, jd, alpha0, delta0
eq2hor, alpha0, delta0, jd, alt_sun, az, ha,  OBSNAME=obsname
	observe=0
        if (alt_moon ge 30. and alt_sun lt -5 and (k gt 0.15 and k lt 0.85)) then observe=1
	if (observe eq 1) then printf,5,format='(f20.5,3(1x,f8.4))', jd,alt_moon,alt_sun,k
	if (observe eq 1) then print,format='(f20.5,3(1x,f8.4))', jd,alt_moon,alt_sun,k
endfor
close,5
data=get_data('p.dat')
jd=reform(data(0,*)) 
alt_moon=reform(data(1,*))
alt_sun=reform(data(2,*))
illfrac=reform(data(3,*))
n=n_elements(jd)
integer_jd=long(jd)
uniq_ijd=integer_jd(uniq(integer_jd))
n=n_elements(uniq_ijd)
openw,6,'start_stop_observing_times.dat'
fmt='(3(1x,f20.7))'
for i=0,n-1,1 do begin
idx=where(long(jd) eq uniq_ijd(i))
if (idx(0) eq -1) then stop
start=min(jd(idx))
stop=max(jd(idx))
print,format=fmt,uniq_ijd(i),start,stop
printf,6,format=fmt,uniq_ijd(i),start,stop
endfor
close,6
end

