From pth@dmi.dk Mon Mar  1 16:30:32 2010
Return-Path: <pth@dmi.dk>
Received: from fep25.mail.dk ([130.226.71.185]) by fep31.mail.dk (InterMail
 vM.7.09.02.02 201-2219-117-103-20090326) with ESMTP id
 <20100301153032.JFU14198.fep31.mail.dk@fep25.mail.dk> for <thejll@mail.dk>;
 Mon, 1 Mar 2010 16:30:32 +0100
Received: from mailgw.dmi.dk ([130.226.71.185]) by fep25.mail.dk (InterMail
 vG.3.00.04.00 201-2196-133-20080908) with ESMTP id
 <20100301153032.ORLV23111.fep25.mail.dk@mailgw.dmi.dk> for
 <thejll@mail.dk>; Mon, 1 Mar 2010 16:30:32 +0100
Received: from localhost (localhost.dmi.dk [127.0.0.1]) by mailgw.dmi.dk
 (8.12.3/8.12.11/Debian-1) with ESMTP id o21FED2U000354 for
 <thejll@mail.dk>; Mon, 1 Mar 2010 15:14:13 GMT
Received: from mailgw.dmi.dk ([127.0.0.1]) by localhost (mailgw.dmi.dk
 [127.0.0.1]) (amavisd-new, port 10024) with LMTP id 32131-02-2 for
 <thejll@mail.dk>; Mon, 1 Mar 2010 15:14:12 +0000 (GMT)
Received: from mailserver.dmi.dk (postoffice.dmi.dk [130.226.64.60]) by
 mailgw.dmi.dk (8.12.3/8.12.3/Debian-7.2) with ESMTP id o21FD9HE032719 for
 <thejll@mail.dk>; Mon, 1 Mar 2010 15:13:09 GMT
Received: from localhost (localhost.dmi.dk [127.0.0.1]) by
 mailserver.dmi.dk (Postfix) with ESMTP id 91B332B6F70 for <thejll@mail.dk>;
 Mon,  1 Mar 2010 15:13:09 +0000 (GMT)
Received: from mailserver.dmi.dk ([127.0.0.1]) by localhost
 (postoffice.dmi.dk [127.0.0.1]) (amavisd-new, port 10024) with LMTP id
 15076-01-49 for <thejll@mail.dk>; Mon, 1 Mar 2010 15:13:09 +0000 (GMT)
Received: from pandora.dmi.dk (egregious [130.226.67.115]) by
 mailserver.dmi.dk (Postfix) with ESMTP id 7EF752B6F66 for <thejll@mail.dk>;
 Mon,  1 Mar 2010 15:13:09 +0000 (GMT)
Received: by pandora.dmi.dk (Postfix, from userid 1099) id 3B4CB4EDE7; Mon,
 1 Mar 2010 16:13:08 +0100 (CET)
To: thejll@mail.dk
Subject: files
Message-Id: <20100301151309.3B4CB4EDE7@pandora.dmi.dk>
Date: Mon,  1 Mar 2010 16:13:08 +0100 (CET)
From: pth@dmi.dk (Peter Thejll)
X-Virus-Scanned: Debian amavisd-new at dmi.dk
X-Virus-Scanned: by amavisd-maia-1.0.0-rc5 (Debian) at dmi.dk
X-CM-Analysis: v=1.1 cv=xHcUj1mXeRHx/mDvuWMTEIDEzI0g43mvnnCHAi9WHE8= c=1
 sm=0 a=K4R8LXkrXniH8spjYSGWBg==:17 a=S7HwN3RCwCoFMPMZq1gA:9
 a=VlO3zRkXklgkC1k6LuP1-vVtZqMA:4 a=HpAAvcLHHh0Zw7uRqdWCyQ==:117
X-Evolution-Source: pop://120100934280@pop3.mail.dk/
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit

PRO evaluate_regression,idx_testset,y_in,x_in,a,b
 common reconstructions,Treconstructed
 x=x_in
 y=y_in
 ; First build the reconstructed T
 l=size(x,/dimensions)
 nproxies=l(0)
 nt=l(1)
 t=findgen(nt)*0.0d0
 for iproxy=0,nproxies-1,1 do T=T+b(iproxy)*x(iproxy,*)
 T=T+a
 Treconstructed=T(idx_testset)
 ; then test 6 different skills
 evaluate_skill,y(idx_testset),T(idx_testset),skills,ab_estimated,ab_actual
 print,skills
 return
 end
 
 
 PRO do_regression,imethod,y_in,x_in,a_found,b_found
 x=x_in
 y=y_in
 if (imethod eq 1) then begin
     ; REGRESS
     res=REGRESS(x,y,/double,yfit=yhat,const=konst)
     a_found=konst
     b_found=reform(res)
     endif
 return
 end
 
 PRO generate_data,n,T,proxies,nproxies,a,b,eta,rho,i_case
 proxies=dblarr(nproxies,n)
 T=dindgen(n)*0.0d0
 dummy=randomn(seed,n)
 ; generate the proxies as red series with AR1=0.7
 for iproxy=0,nproxies-1,1 do begin
     proxies(iproxy,*)=pseudo_t_guarantee_ac1(dummy,0.7,1,seed)  
     proxies(iproxy,*)=proxies(iproxy,*)+exp((indgen(n)-n*(12./15.))/30.0)
     endfor
 ; then generate T from the pseudo-proxies
 for iproxy=0,nproxies-1,1 do begin
     T=T+reform(b(iproxy)*proxies(iproxy,*))
     endfor
 T=T+a
; if want noise on proxies add this
  if (i_case eq 1) then begin
 for iproxy=0,nproxies-1,1 do begin
         noise=pseudo_t_guarantee_ac1(dummy,rho,1,seed)  ; noise AR1=rho
         noise=noise-mean(noise)
         noise=noise/stddev(noise)
         proxies(iproxy,*)=reform(proxies(iproxy,*))+eta*noise
     endfor
 endif
; if i_case eq 2 then want noise on T
 if (i_case eq 2) then T=T+eta*pseudo_t_guarantee_ac1(dummy,rho,1,seed)
 ; normalize proxies
 for iproxy=0,nproxies-1,1 do begin
     proxies(iproxy,*)=proxies(iproxy,*)-mean(proxies(iproxy,*))
     proxies(iproxy,*)=proxies(iproxy,*)/stddev(proxies(iproxy,*))
     endfor
 ; normalize the temperature
	T=T-mean(t)
	T=T/stddev(T)
 return
 end
 
 ; Version 15
 ; code to test OLS vs CO etc on reconstruction simulations
 ; MULTI-variate
 ;---------------------------------------------------------------------
 !X.THICK=2
 !Y.THICK=2
 !P.THICK=2
 !P.CHARSIZE=2
 common reconstructions,Treconstructed
 nproxies=20
 n=150	; length of the time series 
 time=findgen(n)
 idx=indgen(n)
 fraction=0.7	; division of the time axis into trainand test sets
 ; define the training set and the test set
 idx_trainset=where(time ge fraction*max(time))
 idx_testset=where(time le fraction*max(time))
 rho=0.7	; AR1 of proxies
 eta=0.1	; factor on noise
 ; set up the regression coefficients that 'really' apply
 a=17.0
 b=randomn(seed,nproxies,/double)	; regression coefficients
 ; choose the noise model
 i_case=1
 ; choose the regression method
 imethod=1
 ; go and generate fake AR1 proxies and generate a T
 generate_data,n,T,proxies,nproxies,a,b,eta,rho,i_case
 print,'Moment of T:',moment(T)
 for ip=0,nproxies-1,1 do print,'Moment of proxy:',ip,moment(proxies(ip,*))
 plot,time,T,xtitle='Time',ytitle='T, and reconstructions'
 plots,[fraction*n,fraction*n],[!Y.CRANGE],linestyle=2
 ; perform the regression using training data
 do_regression,imethod,t(idx_trainset),proxies(*,idx_trainset),a_found,b_found
 for ik=0,nproxies-1,1 do begin
     print,ik,b(ik),b_found(ik)
     endfor
 print,a,a_found
 ; evaluate the regression on the test set
 evaluate_regression,idx_testset,t,proxies,a_found,b_found
 oplot,time(idx_testset),Treconstructed,color=fsc_color('red')
 end

